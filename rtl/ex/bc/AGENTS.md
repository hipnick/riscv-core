# Branch Comparator (BC) Specification

The Branch Comparator is a combinational module that evaluates condition codes for B-type instructions. It determines whether a branch should be taken based on the relationship between two source registers.

## BC Operation Table

| BC Control (3-bit) | Mnemonic | Instruction(s) | Description |
| :--- | :--- | :--- | :--- |
| `3'b000` | **BC_BEQ** | `beq` | Branch if Equal |
| `3'b001` | **BC_BNE** | `bne` | Branch if Not Equal |
| `3'b100` | **BC_BLT** | `blt` | Branch if Less Than (Signed) |
| `3'b101` | **BC_BGE** | `bge` | Branch if Greater than or Equal (Signed) |
| `3'b110` | **BC_BLTU** | `bltu` | Branch if Less Than (Unsigned) |
| `3'b111` | **BC_BGEU** | `bgeu` | Branch if Greater than or Equal (Unsigned) |

## Interface Specification

| Signal | Dir | Type | Description |
| :--- | :--- | :--- | :--- |
| `bc_ctrl_i` | I | bc_ctrl_e | Operation selector (from `funct3`) |
| `op_a_i` | I | data_t | Source operand A (from `rs1`) |
| `op_b_i` | I | data_t | Source operand B (from `rs2`) |
| `bc_taken_o` | O | logic | Asserted if comparison is true |

## Functional Specifications

### 1. Comparison Logic
The BC evaluates the relationship between `op_a_i` and `op_b_i` combinationally. The output `bc_taken_o` is used by the Control Unit to multiplex the next Program Counter (PC) value between `PC + 4` and the `Target Address`.

### 2. Signed vs. Unsigned Handling
- **Signed:** Comparisons (`BC_BLT`, `BC_BGE`) must treat operands as 2's complement integers using the `$signed()` cast.
- **Unsigned:** Comparisons (`BC_BLTU`, `BC_BGEU`) must treat operands as unsigned magnitudes.

### 3. Default State
If `bc_ctrl_i` does not match a valid branch mnemonic, or if no branch instruction is being executed, `bc_taken_o` must default to `0` to prevent accidental jumps.