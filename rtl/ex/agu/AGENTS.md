# Address Generation Unit (AGU) Specification

The Address Generation Unit (AGU) is a dedicated combinational module within the Execute (EX) stage. It calculates the next Program Counter (PC) value for control-flow instructions (Jumps and Branches) independently of the main ALU to maintain pipeline performance.

## 1. Architecture Overview
The AGU implements a specialized 32-bit adder with input multiplexing to support both PC-relative and absolute-indirect addressing modes. It also ensures hardware-level compliance with RISC-V instruction alignment requirements.

## 2. Interface Specification

| Signal | Direction | Type | Description |
| :--- | :--- | :--- | :--- |
| `pc_i` | Input | data_t | Program Counter of the current instruction in the EX stage. |
| `imm_i` | Input | data_t | Sign-extended immediate value (offset) from the ID stage. |
| `op_a_i` | Input | data_t | Source register 1 (`rs1`) data, used as a base for `JALR`. |
| `jalr_sel_i` | Input | logic | Control signal; High for `JALR`, Low for `JAL` and Branches. |
| `target_addr_o` | Output | data_t | The calculated 32-bit jump/branch target address. |

## 3. Functional Specifications

### 3.1 Base Address Selection
The AGU selects the base for addition based on the `jalr_sel_i` control signal:
- **PC-Relative:** `target_base = pc_i` (Used for `JAL` and all B-type branch instructions).
- **Absolute-Indirect:** `target_base = op_a_i` (Used exclusively for `JALR`).

### 3.2 Target Calculation and Alignment
The unit performs a standard 32-bit addition of the selected base and the immediate offset. To comply with the RISC-V ISA specification (which requires branch/jump targets to be aligned), the least significant bit (LSB) is explicitly cleared.
- **Formula:** `target_addr_o = (target_base + imm_i) & ~32'h1`

### 3.3 Performance Design
As a strictly combinational module (`assign` based), the AGU provides the `target_addr_o` within the same clock cycle it receives its operands. This allows the Instruction Fetch (IF) stage to receive the new PC value immediately, minimizing