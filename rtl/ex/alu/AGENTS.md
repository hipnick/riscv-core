# The Arithmetic Logic Unit (ALU) Specification

The Arithmetic Logic Unit is a combinational module for RV32I ISA that handles arithmetic, logical, and shift operations.

## Operation Table

| ALU Control (4-bit) | Operation | Instruction(s) | Description |
| :--- | :--- | :--- | :--- |
| `4'b0000` | **AND** | `and`, `andi` | Bitwise AND |
| `4'b0001` | **OR** | `or`, `ori` | Bitwise OR |
| `4'b0010` | **ADD** | `add`, `addi`, `load`, `store`, `auipc` | Addition |
| `4'b0110` | **SUB** | `sub` | Subtraction |
| `4'b0100` | **XOR** | `xor`, `xori` | Bitwise XOR |
| `4'b1000` | **SLL** | `sll`, `slli` | Shift Left Logical |
| `4'b1001` | **SRL** | `srl`, `srli` | Shift Right Logical |
| `4'b1010` | **SRA** | `sra`, `srai` | Shift Right Arithmetic (Sign-preserved) |
| `4'b1100` | **SLT** | `slt`, `slti` | Set Less Than (Signed) |
| `4'b1101` | **SLTU** | `sltu`, `sltiu` | Set Less Than (Unsigned) |
| `4'b1111` | **COPY_B** | `lui` | Pass-through Operand B|


## ALU Interface Specification (RV32I)

| Signal | Dir | Type | Description |
| :--- | :--- | :--- | :--- |
| `alu_ctrl_i` | I | alu_ctrl_e | Operation selector |
| `op_a_i` | I | data_t | Source operand A |
| `op_b_i` | I | data_t | Source operand B |
| `alu_result_o` | O | data_t | 32-bit Result |
| `alu_zero_o` | O | logic | High if result is alu_zero_o |
| `alu_negative_o` | O | logic | High if result is alu_negative_o |
| `alu_overflow_o` | O | logic | High if signed alu_overflow_o occurs |

## Functional Specifications

### 1. Arithmetic & Logic
The ALU performs 32-bit operations based on the `alu_ctrl_i` input. All logical operations are bitwise. Arithmetic operations use 2's complement representation.

### 2. Comparison Instructions (SLT/SLTU)
- **SLT (Signed):** `alu_result_o = ($signed(op_a_i) < $signed(op_b_i)) ? 1 : 0`
- **SLTU (Unsigned):** `alu_result_o = (op_a_i < op_b_i) ? 1 : 0`

### 3. Shifter Logic
The shifter implements Logical Left, Logical Right, and Arithmetic Right shifts. 
- **Shift Amount:** Bound to `op_b_i[4:0]`.
- **SRA (Arithmetic):** Must perform sign-extension of the MSB to maintain 2's complement integrity.

### 4. Status Signals
- `alu_zero_o`: Asserted if all bits of `alu_result_o` are 0.
- `alu_negative_o`: Directly mapped to `alu_result_o[31]`.
- `alu_overflow_o`: Asserted during `ADD` or `SUB` if the result exceeds the 32-bit signed range.