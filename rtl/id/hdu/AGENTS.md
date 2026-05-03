# Hazard Detection Unit (HDU) Specification

The **Hazard Detection Unit** is a combinational logic block situated within the ID stage. Its primary role is to identify "Load-Use" data hazards—situations where an instruction in the Decode stage depends on data being loaded from memory by the preceding instruction. 

## 1. Functional Description
The HDU monitors the destination register of the instruction currently in the Execute (EX) stage. If that instruction is a `Load` and its destination matches a source register of the instruction currently being decoded in the ID stage, the HDU must:
*   **Stall the Fetch Stage:** Set `pc_write_o` to LOW to freeze the Program Counter.
*   **Stall the Decode Stage:** Set `if_id_write_o` to LOW to keep the current instruction in the IF/ID register.
*   **Inject a Bubble:** Set `stall_o` to HIGH to multiplex the ID/EX control signals to zero (NOP).

## 2. Interface Definition

| Signal            | Dir | Type      | Source         | Description                                          |
| :---------------- | :-- | :-------- | :------------- | :--------------------------------------------------- |
| `rs1_addr_id_i`   | I   | address_t | IF/ID Register | Source register 1 address in ID stage.               |
| `rs2_addr_id_i`   | I   | address_t | IF/ID Register | Source register 2 address in ID stage.               |
| `rd_addr_ex_i`    | I   | address_t | ID/EX Register | Destination register address in EX stage.            |
| `mem_read_ex_i`   | I   | logic     | ID/EX Register | High if instruction in EX is a Load (e.g., `LW`).    |
| `pc_write_o`      | O   | logic     | PC Register    | Enable signal for PC. Set to 0 to stall.             |
| `if_id_write_o`   | O   | logic     | IF/ID Register | Enable signal for IF/ID register. Set to 0 to stall. |
| `stall_o`  | O   | logic     | ID/EX Register | Signal to force a NOP into the EX stage.             |

## 3. Hazard Detection Logic Requirements
The stall condition must be evaluated combinationally. A stall is required if:
1.  The instruction in the EX stage is a Memory Read (`mem_read_ex_i == 1`).
2.  The destination register of the EX stage instruction (`rd_addr_ex_i`) matches either `rs1_addr_id_i` or `rs2_addr_id_i`.
3.  The destination register `rd_addr_ex_i` is not `x0`.

## 4. Implementation Requirements
*   **Priority over Forwarding:** The HDU effectively "wins" over the Forwarding unit. If the HDU stalls the pipeline, the Forwarding unit will see the updated (stalled) registers in the next cycle.
*   **Combinational Path:** Must be implemented in an `always_comb` block to ensure the `pc_write_o` and `if_id_write_o` signals meet the setup time for the pipeline registers.
*   **Default State:** In the absence of a hazard, `pc_write_o` and `if_id_write_o` must default to HIGH (1), and `stall_o` must default to LOW (0).