# Instruction Decode (ID) Stage Specification

The **Instruction Decode (ID) Stage** is responsible for parsing raw machine code from the Instruction Fetch (IF) stage. It extracts source/destination register addresses, decodes the immediate values, and generates the control signals necessary for the Execute (EX), Memory (MEM), and Write-Back (WB) stages.

## 1. Architecture Overview
The ID stage consists of four primary functional blocks:
1.  **Control Unit (CU):** Decodes the `opcode`, `funct3`, and `funct7` fields to generate global control signals.
2.  **Immediate Generator:** Extracts and sign-extends immediate values based on the instruction format (I, S, B, U, J).
3.  **Register File (RF):** A dual-port read/single-port write storage for the 32 general-purpose registers (`x0-x31`).
4.  **Hazard Detection Unit:** Monitors for data dependencies that cannot be resolved by forwarding (e.g., Load-Use hazards) and generates pipeline stalls.

---

## 2. Interface Definition

### Input Signals
| Signal | Type | Source Stage | Description |
| :--- | :--- | :--- | :--- |
| `clk_i` | `logic` | Global | System clock signal. |
| `rst_ni` | `logic` | Global | Asynchronous active-low reset. |
| `instr_i` | `data_t` | IF (Fetch) | 32-bit raw instruction to be decoded[cite: 1, 2]. |
| `pc_i` | `data_t` | IF (Fetch) | Program Counter of the current instruction. |
| `wb_addr_i` | `address_t` | WB (Writeback) | Destination register address for the current write cycle. |
| `wb_data_i` | `data_t` | WB (Writeback) | Data value to be written into the Register File. |
| `reg_we_i` | `logic` | WB (Writeback) | Write enable for the Register File. |
| `ex_rd_addr_i` | `address_t` | EX (Execute) | Destination register address of the instruction currently in Execute. |
| `ex_mem_read_i` | `logic` | EX (Execute) | High if the instruction in EX is a Load (used for hazard detection). |

### Output Signals
| Signal | Type | Destination | Description |
| :--- | :--- | :--- | :--- |
| `alu_ctrl_o` | `alu_ctrl_e` | EX (Execute) | ALU operation selection code. |
| `operand_a_o` | `data_t` | EX (Execute) | First ALU operand (Register RS1 or PC)[cite: 1, 2]. |
| `operand_b_o` | `data_t` | EX (Execute) | Second ALU operand (Register RS2 or Immediate). |
| `rs1_addr_o` | `address_t` | EX (Execute) | Address of source register 1 (used for Forwarding Unit). |
| `rs2_addr_o` | `address_t` | EX (Execute) | Address of source register 2 (used for Forwarding Unit). |
| `rd_addr_o` | `address_t` | EX (Execute) | Destination register address. |
| `alu_src_o` | `logic` | EX (Execute) | Control signal selecting Operand B source (0: Reg, 1: Imm). |
| `mem_we_o` | `logic` | MEM (Memory) | Data Memory write enable signal. |
| `reg_we_o` | `logic` | WB (Writeback) | Register File write enable signal for the instruction. |
| `branch_o` | `logic` | EX (Execute) | Indicates a conditional branch instruction. |
| `jump_o` | `logic` | EX (Execute) | Indicates an unconditional jump (JAL/JALR). |
| `mem_to_reg_o` | `logic` | WB (Writeback) | Selects between ALU result (0) and Memory (1) for WB. |
| `stall_o` | `logic` | Pipeline | Stall signal indicating a Load-Use hazard. |
| `pc_write_o` | `logic` | IF (Fetch) | Enable signal for the Program Counter register. |
| `if_id_write_o` | `logic` | Pipeline | Enable signal for the IF/ID pipeline register. |

---

## 3. Instruction Format Decoding
The Immediate Generator must handle the following RISC-V standard formats:

| Type | Instruction Example | Immediate Extraction Logic (SystemVerilog Syntax) |
| :--- | :--- | :--- |
| **I-Type** | `addi`, `lw` | `{{20{instr_i[31]}}, instr_i[31:20]}` |
| **S-Type** | `sw` | `{{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]}` |
| **B-Type** | `beq` | `{{19{instr_i[31]}}, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0}` |
| **U-Type** | `lui` | `{instr_i[31:12], 12'b0}` |
| **J-Type** | `jal` | `{{11{instr_i[31]}}, instr_i[31], instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0}` |