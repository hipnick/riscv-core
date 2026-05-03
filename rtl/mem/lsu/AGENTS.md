# LSU Sign-Extension and Alignment Logic

## Architectural Scaling (RV32 vs RV64)
The LSU must adapt its sign-extension behavior based on the `DATA_WIDTH` parameter. In RISC-V, the register file always stores a full `DATA_WIDTH` value.

| Instruction | Sub-type Width | RV32 Behavior | RV64 Behavior |
| :--- | :--- | :--- | :--- |
| **LB** (Byte) | 8 bits | Sign-ext to 32 | Sign-ext to 64 |
| **LH** (Half) | 16 bits | Sign-ext to 32 | Sign-ext to 64 |
| **LW** (Word) | 32 bits | No extension | Sign-ext to 64 |

## Ports
| Name            | Direction | Type              | Description                                                                 |
|:----------------|:----------|:------------------|:------------------|
| **lsu_op_i**    | Input     | lsu_op_e          | Selects operation type and width (LB, LH, LW, LBU, LHU, SB, SH, SW).        |
| **addr_i**      | Input     | data_t            | The base address calculated by the ALU.                                    |
| **wdata_i**     | Input     | data_t            | Data from the Register File to be written to memory.                       |
| **mem_rdata_i** | Input     | data_t            | Raw data received from the Memory Bus.                                     |
| **mem_write_i** | Input     | logic             | Global write enable signal from the Control Unit.                          |
| **mem_wdata_o** | Output    | data_t            | Shifted/aligned data sent to the Memory Bus.                               |
| **mem_be_o**    | Output    | [BYTES-1:0] logic | Byte Enable (Strobe) signals for partial word writes.                      |
| **lsu_rdata_o** | Output    | data_t            | Aligned and sign-extended data sent to the Write-back stage.               |

## Alignment Theory
To calculate the bit-shift required for a load or store, we use the formula:
$$ShiftAmount = ByteOffset \times 8$$

For a 64-bit system, the `ByteOffset` is derived from `addr_i[2:0]` (3 bits), whereas for 32-bit it is `addr_i[1:0]` (2 bits).
