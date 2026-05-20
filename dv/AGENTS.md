# RISC-V Core Pipelined UVM Verification Plan

## 1. Overview & Strategy
This document outlines the advanced, production-grade verification strategy for the 5-stage pipelined RISC-V Processor Core (core_top.sv). 

To isolate concurrent pipeline bugs (e.g., forwarding paths, hazard stalls, branch mispredictions), this framework deploys a **full IEEE 1800.2 Universal Verification Methodology (UVM)** environment. The design leverages a single, highly configurable UVM environment that transitions dynamically through four distinct execution phases, moving from deterministic directed smoke code up to automated, metric-driven, constrained-random transaction streams.

---

## 2. UVM Architecture & Class Topology

The verification environment utilizes standard UVM base classes, transactions, and TLM 1.0 communication ports to completely decouple test intent from physical pin-level driving.

### Component Breakdown
* **core_tb.sv (Hardware Top Module):** The non-synthesizable structural top-level container. It instantiates the core_top DUT, implements a dual-port behavioral memory model, manages the global system clock/reset lines, and registers the virtual interfaces into the UVM Configuration Database via uvm_config_db.
* **riscv_instr_tx (UVM Sequence Item):** The core data abstraction class extending uvm_sequence_item. It contains randomized variables representing the fields of an instruction (Opcode, rs1, rs2, rd, immediate values) decorated with strict ISA constraint rules.
* **core_env (UVM Environment Class):** Container class extending uvm_env that instantiates, configures, and hooks up the downstream structural agents and verification components.
* **imem_dmem_agent (UVM Agent):** Encapsulates the tracking loops for the core's bus interfaces. Configured as an ACTIVE agent containing:
  * **mem_sequencer (uvm_sequencer):** Arbitrates and feeds sequence items from incoming test sequences down to the driver.
  * **mem_driver (uvm_driver):** Receives riscv_instr_tx transactions. For directed phases, it loads binaries via backdoor tasks. For randomized phases, it pulls instructions from the sequencer on-the-fly and translates transactions into cycle-accurate bus operations.
  * **mem_monitor (uvm_monitor):** Passively samples pin-level execution (Instruction addresses, data memory transactions, writeback updates) and broadcasts transaction objects over an uvm_analysis_port.
* **core_scoreboard (uvm_scoreboard):** Implements uvm_analysis_imp hooks to consume data packets sent by the monitor. It maintains an independent, internal reference model tracking expected register modifications to catch data path deviations immediately.

---

## 3. Phased Verification Execution Roadmap

Verification targets the complete core topology across four distinct phases by varying the UVM Test sequence applied to the environment.

### Phase 1: Directed Assembly Smoke Tests (test_straight_line)
* **Objective:** Verify basic 5-stage structural propagation (Fetch -> Decode -> Execute -> Memory -> Write-back) completely free of data dependencies or control logic jumps.
* **Payload Code (smoke.mem):** A sequence of isolated addi and lui instructions targeting mutually exclusive registers.
* **Pass Criteria:** Registers reflect exact mathematical additions; PC increments by exactly +4 every clock cycle without pipeline bubbles.

### Phase 2: Structural Pipeline Hazard Stress Tests (test_hazards)
* **Objective:** Validate the dynamic control logic (Forwarding Unit u_fwd and Hazard Detection Unit u_hdu).
* **Payload Code Sequences:**
  1. **Raw Data Hazard (hazard_raw.mem):** Immediate back-to-back register consumers to stress-test bypass paths.
  2. **Load-Use Hazard (hazard_load.mem):** A memory load followed immediately by an ALU instruction consuming that memory destination register, validating that a 1-cycle stall bubble is correctly injected.
  3. **Control Flow Hazard (hazard_control.mem):** bne/beq and jal loops to verify that branch comparison mispredictions correctly flush out late-stage instructions and redirect execution to target correction addresses.
* **Pass Criteria:** Zero data corruption across hazards; stall signals and flush flags clear exactly when dependencies are satisfied.

### Phase 3: Freestanding Compiled C Programs (test_c_freestanding)
* **Objective:** Execute arbitrary compiled C code on production-grade compilation pipelines.
* **Toolchain Requirements:** RISC-V GCC cross-compiler targeting the rv32i base ISA.
* **Compilation Details:** Compilation must use the march=rv32i, mabi=ilp32, ffreestanding, nostdlib, and optimization flags to avoid system calls or unsupported software traps.
* **Custom Linker Script (linker.ld):** Forces the text section base vector layout directly to address 0x0000_0000 to align perfectly with the core's reset Program Counter.
* **Pass Criteria:** Successful completion of embedded algorithmic execution (e.g., Fibonacci, Matrix multiplication) proven via Write-back register values or dedicated memory-mapped IO termination addresses.

### Phase 4: Constrained-Random Instruction Streams (test_random_sequence)
* **Objective:** Discover extreme corner-case pipeline bugs by hammering the core with completely unscripted, randomized streams of legal instructions.
* **Mechanism:** Activates a dedicated UVM Sequence (random_instr_seq) that randomizes hundreds of consecutive riscv_instr_tx transaction items.
* **UVM Constraints:**
  * legal_opcodes: Restricts random selection exclusively to valid supported RV32I opcodes (OP_R_TYPE, OP_I_TYPE, OP_LOAD, OP_STORE, OP_BRANCH).
  * avoid_x0_dest: Restricts destination register choices away from register x0 for 95% of transactions to ensure hazardous dependencies are aggressively generated across sequential registers.
  * intermittent_branches: Generates randomized branch offsets that intentionally target both preceding and forward instructions to force randomized flushes.
* **Pass Criteria:** Zero pipeline lockups, deadlock conditions, or state miscomparisons in the Scoreboard over 10,000 continuous randomized instructions.

---

## 4. SystemVerilog Functional/Code Coverage under Verilator

Since Verilator optimizes simulation via compilation into static C++, tracking verification thoroughness follows a dual-track strategy:

1. **Structural Code Coverage:** Compiled using the coverage flag to automatically track line, branch, and toggle coverage throughout the pipeline logic. Results are viewed via verilator_coverage HTML outputs.
2. **Functional Event Coverage:** Since Verilator does not natively implement traditional SystemVerilog covergroup constructs, functional coverage is achieved via SystemVerilog Assertions (SVA) Cover Properties mapped inside the monitoring layers. For example, the environment explicitly covers the state where a load-use hazard occurs concurrently with an active hazard detection unit stall flag.
---