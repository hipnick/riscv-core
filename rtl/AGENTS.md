# Module Specification: core_top

## 1. Overview
The `core_top` module is the structural anchor of the `riscv-core` pipeline. It acts as the top-level parent component, establishing the definitive wiring layout for data paths, control paths, hazard mitigation logic, and external bus interfaces. 

Its primary function is to structurally instantiate and interconnect:
* The 5 classic RISC-V pipeline stages (Fetch, Decode, Execute, Memory, Write-back).
* Intermediary pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB).
* The Hazard Detection Unit (HDU) and Forwarding Unit (FU).

---

## 2. Hardware vs. Software Mental Model
To bridge the gap between reactive user-interface rendering and cycle-accurate hardware execution, use the following structural analogies:

* **Structural Composition (`core_top.sv` as `App.tsx`):** In React, `App.tsx` layout components do not calculate business logic themselves; they instantiate sub-components and pass data down via props. Similarly, `core_top.sv` performs no logical operations or signal transformations. It structurally maps output ports of one stage wrapper to the input ports of pipeline registers or subsequent stages.
* **State Propagation (Pipeline Registers as Global Immutable State Snapshots):** Think of the pipeline registers (e.g., `if_id_reg`, `id_ex_reg`) as deterministic state snapshots. At every rising clock edge (`posedge clk`), the current state is captured and made available immutably to the next stage for the duration of that clock cycle. This matches the behavior of passing an immutable state snapshot down a re-rendering component tree.
* **Component Communication (Ports as Explicit Component Props):** Every module instantiation inside `core_top.sv` uses strict port mapping, which mirrors passing typed props into nested React functional components.

---

## 3. Data and Control Flow Architecture

### 3.1 Structural Topology Block Diagram
The pipeline flows from left (Fetch) to right (Write-back), with specialized feedback loops for hazard stalling and data forwarding managed at the top-level layer.

+---------+     +---------+     +---------+     +---------+     +---------+
   |  FETCH  |---->| DECODE  |---->| EXECUTE |---->| MEMORY  |---->| WRITEB. |
   |  STAGE  |     |  STAGE  |     |  STAGE  |     |  STAGE  |     |  STAGE  |
   +---------+     +---------+     +---------+     +---------+     +---------+
        ^               |               |               |               |
        |               v               v               v               |
        |         +-------------------------------------------+         |
        |         |          Hazard Detection Unit            |         |
        +---------|            & Forwarding Unit              |<--------+
Stall / Flush Bits+-------------------------------------------+ Feedback Loops

### 3.2 Signal Interconnections
* **Instruction Slicing:** The Instruction Fetch stage provides a raw 32-bit instruction (`data_t`). The `core_top` routing passes this instruction into the Decode stage, where opcode fields matching `opcode_e` and function slices (`funct3_e`, `funct7_e`) are unpacked.
* **Forwarding Paths:** The Forwarding Unit inside `core_top` samples destination registers and write-enable bits from the Execute, Memory, and Write-back boundaries. It dynamically drives multiplexer select lines routed into the Execute stage ALU inputs to resolve raw data hazards without stalling.
* **Interstage Interlocks:** The Hazard Detection Unit evaluates load-use dependencies and branch execution outcomes. It asserts control flags (`stall`, `flush`) that interface directly with the pipeline registers' clock-enables and synchronous clear inputs.

---

## 4. Interface Definition

### 4.1 Global Infrastructure Signals
| Signal Name | SystemVerilog Type | Direction | Description |
| :--- | :--- | :--- | :--- |
| `clk_i` | `logic` | Input | Master System Clock. All internal state updates trigger on the `posedge`. |
| `rst_ni` | `logic` | Input | Master Active-Low Asynchronous Reset. |

### 4.2 Instruction Memory Bus Interface (Instruction Fetch)
| Signal Name | SystemVerilog Type | Direction | Description |
| :--- | :--- | :--- | :--- |
| `instr_addr_o` | `data_t` | Output | Instruction Program Counter address sent to external ROM/RAM. |
| `instr_data_i` | `data_t` | Input | Raw 32-bit machine instruction word fetched from memory. |

### 4.3 Data Memory Bus Interface (Memory Stage)
| Signal Name | SystemVerilog Type | Direction | Description |
| :--- | :--- | :--- | :--- |
| `dmem_addr_o` | `data_t` | Output | Calculated memory target address for load/store operations. |
| `dmem_wdata_o` | `data_t` | Output | Store data payload written to external Data Memory. |
| `dmem_we_o` | `logic` | Output | Write-enable strobe line active for `OP_STORE` instructions. |
| `dmem_rdata_i` | `data_t` | Input | Retreived data payload returned from external Data Memory. |

---