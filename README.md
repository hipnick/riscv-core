# RISC-V (RV32I) core
This is a professional, industry-standard RISC-V (RV32I) core, to showcase my understanding of EDA Automation concepts. This is the "Gold Standard" for entry-level silicon design as it mirrors the classic DLX/MIPS structures while utilizing the RISC-V Instruction Set Architecture (ISA).

It consists of the following stages, organized by their position in the pipeline:

## Stage Pipeline

### 1. Instruction Fetch (IF)
- Program Counter (PC): A register that holds the address of the current instruction.

- Instruction Memory (IMEM) Interface: While memory is often external, you need a module to handle the request/acknowledge handshake to fetch the 32-bit instruction word.

- Branch Target Buffer / Adder: A simple adder to calculate PC + 4.

### 2. Instruction Decode (ID)
- Control Unit: The "brain" that parses the Opcode and generates control signals for the rest of the pipeline.

- Register File (RegFile): A 32x32-bit dual-read/single-write memory block. Note: In RISC-V, x0 is hardwired to alu_zero_o.

- Immediate Generator: Extracts and sign-extends imm_i values from various instruction formats (I, S, B, U, J types).

- Hazard Detection Unit: The software-logic equivalent of a "lock." It detects data hazards (using a value before it's written) and inserts "stalls" (NOPs).

### 3. Execute (EX)
- ALU : Perform arithmetic and logic. You will need to update yours to support RISC-V specific operations like SLT (Set Less Than) and ensuring shifts handle the 5-bit shamt correctly.

- Branch Comparator: Compares registers (e.g., BEQ, BNE) to determine if a branch should be taken.

- Forwarding Unit: Optimizes performance by passing data directly from the ALU output back to the input of the next instruction, bypassing the Register File write-cycle.

- The Address Generation Unit (AGU) calculates the next Program Counter value for control-flow instructions independently of the main ALU to maintain pipeline performance.

### 4. Memory Access (MEM)
- Load/Store Unit: Manages byte alignment (e.g., LB, LH, LW) and sign-extension for partial word loads. Handles Load and Store operations.

### 5. Write Back (WB)
- Write-Back Mux: Selects whether the data being written to the Register File comes from the ALU (arithmetic) or Memory (loads).

### 6. Pipeline Registers (PR)
- Pipeline Registers (IF/ID, ID/EX, EX/MEM, MEM/WB): Flip-flops that sit between stages to hold signals for the next clock cycle.

## Folder Structure
```
riscv-core/
├── rtl/
│   ├── common/                # Shared constants and packages
│   │   └── riscv_types_pkg.sv
│   ├── ex/                    # Execute Stage
│   │   ├── alu/
│   │   │   ├── alu.sv
│   │   └── branch_comp/       # (Follow the same pattern as alu)
│   ├── id/                    # Instruction Decode Stage (Follow the same pattern as ex)
│   └── core_top.sv
├── dv/                         # Design Verification Root
│   ├── tb_top/
│   │   └── core_tb.sv          # Hardware Harness, Virtual Interfaces, Mem Model
│   ├── env/
│   │   ├── core_env_pkg.sv     # UVM Package wrapping all components
│   │   ├── riscv_instr_tx.sv   # Transaction object extending uvm_sequence_item
│   │   ├── core_env.sv         # Environment Class extending uvm_env
│   │   ├── core_scoreboard.sv  # Scoreboard extending uvm_scoreboard
│   │   └── memory_agent/
│   │       ├── mem_agent.sv    # Agent extending uvm_agent
│   │       ├── mem_sequencer.sv# Sequencer extending uvm_sequencer
│   │       ├── mem_driver.sv   # Driver extending uvm_driver
│   │       └── mem_monitor.sv  # Monitor extending uvm_monitor
│   ├── sequences/
│   │   ├── core_base_seq.sv    # Parent Base Sequence
│   │   └── random_instr_seq.sv # Phase 4 Constrained Random Sequence
│   ├── tests/
│   │   ├── core_base_test.sv   # Parent Base Test extending uvm_test
│   │   ├── test_smoke.sv       # Phase 1 Test Case
│   │   ├── test_hazards.sv     # Phase 2 Test Case
│   │   ├── test_c_runtime.sv   # Phase 3 Test Case
│   │   └── test_random.sv      # Phase 4 Test Case
│   └── sw/                     # Software Target Sources
│       ├── asm/                # Handcrafted direct .s or .mem source strings
│       ├── c_src/              # Freestanding C source code scripts (.c)
│       └── linker.ld           # Custom memory map layout script
├── sim/                       # Verilator, Simulation scripts & build artifacts
└── doc/                       # Specs and documentation
```