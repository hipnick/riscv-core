# Control Unit (CU) Specification

The **Control Unit** is a purely combinational block within the ID stage. It decodes the RISC-V opcode, funct3, and funct7 fields to generate control signals that dictate the behavior of the Execute (EX), Memory (MEM), and Write-Back (WB) stages.

## 1. Functional Description
The CU implements the decoding logic for the RV32I Base Integer Instruction Set. It determines:
*   Whether the ALU should perform an operation and which one.
*   Whether the instruction involves a memory read or write.
*   Whether the result should be written back to the Register File.
*   The source of the second ALU operand (Register vs. Immediate).

## 2. Interface Definition

### Input Signals
| Signal      | Width | Description                                     |
| :---------- | :---- | :---------------------------------------------- |
| `opcode_i`  | opcode_e | Instruction opcode (instr_i[6:0]).             |
| `funct3_i`  | funct3_e | Instruction funct3 field (instr_i[14:12]).      |
| `funct7_i`  | funct7_e | Instruction funct7 field (instr_i[31:25]).      |

### Output Signals
| Signal        | Type          | Destination | Description                                             |
| :------------ | :------------ | :---------- | :------------------------------------------------------ |
| `alu_ctrl_o`    | alu_ctrl_e    | EX Stage    | Decoded ALU operation (e.g., ADD, SUB, AND).            |
| `alu_src_o`   | logic         | EX Stage    | Selects ALU operand B: 0 = rs2_data, 1 = immediate.     |
| `mem_to_reg_o`| logic         | WB Stage    | Selects WB data: 0 = ALU result, 1 = Memory data.       |
| `reg_we_o`    | logic         | WB Stage    | Enables writing to the Register File.                  |
| `mem_we_o`    | logic         | MEM Stage   | Enables writing to Data Memory.                         |
| `branch_o`    | logic         | EX Stage    | Indicates a branch instruction (for PC target logic).   |
| `jump_o`      | logic         | EX Stage    | Indicates a jump instruction (JAL/JALR).                |

## 3. Logic Table (Selection)
The following table maps primary opcodes to internal control states:

| Instruction Type | Opcode    | ALU Src | MemtoReg | RegWrite | MemWrite | Branch | ALUOp (Partial) |
| :--------------- | :-------- | :-----: | :------: | :------: | :------: | :----: | :-------------- |
| R-Type (add/sub) | `0110011` | 0       | 0        | 1        | 0        | 0      | Determined by f3/f7 |
| I-Type (addi)    | `0010011` | 1       | 0        | 1        | 0        | 0      | Determined by f3    |
| Load (lw)        | `0000011` | 1       | 1        | 1        | 0        | 0      | ADD             |
| Store (sw)       | `0100011` | 1       | X        | 0        | 1        | 0      | ADD             |
| Branch (beq)     | `1100011` | 0       | X        | 0        | 0        | 1      | SUB (for comp)  |

## 4. Implementation Requirements
*   **Combinational Logic:** The module must be implemented using `always_comb`.
*   **Type Safety:** ALU operations must use the `alu_ctrl_e` enumerated type defined in the global package.
*   **Default States:** All control signals must have a defined default state (usually 0/disabled) to prevent unintended hardware behavior on illegal instructions.