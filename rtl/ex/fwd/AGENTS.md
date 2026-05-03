# Forwarding Unit (FWD) Specification

The Forwarding Unit is a combinational module responsible for resolving data hazards. It detects when an instruction in the Execute (EX) stage depends on a result from a previous instruction that has not yet been written back to the Register File, and redirects the correct data directly to the ALU inputs.

## Forwarding Selection Table

| Output Value | Mnemonic | Source | Logic Condition (Match Criteria) |
| :--- | :--- | :--- | :--- |
| `2'b00` | **FWD_ID_EX** | ID Stage | Default: No hazards detected; use Register File data. |
| `2'b10` | **FWD_MEM** | MEM Stage | `rs_addr == rd_addr_mem` AND `reg_we_mem` is HIGH. |
| `2'b01` | **FWD_WB** | WB Stage | `rs_addr == rd_addr_wb` AND `reg_we_wb` is HIGH. |

## Interface Specification

| Signal | Dir | Type | Description |
| :--- | :--- | :--- | :--- |
| `rs1_addr_ex_i` | I | address_t | Source register 1 address of current instruction in EX. |
| `rs2_addr_ex_i` | I | address_t | Source register 2 address of current instruction in EX. |
| `rd_addr_mem_i` | I | address_t | Destination register address of instruction in MEM. |
| `rd_addr_wb_i` | I | address_t | Destination register address of instruction in WB. |
| `reg_we_mem_i` | I | logic | Register write enable signal from MEM stage. |
| `reg_we_wb_i` | I | logic | Register write enable signal from WB stage. |
| `fwd_a_o` | O | fwd_ctrl_e | Selection signal for ALU operand A multiplexer. |
| `fwd_b_o` | O | fwd_ctrl_e | Selection signal for ALU operand B multiplexer. |

## Functional Specifications

### 1. Hazard Detection Logic
The FU compares the source addresses of the instruction in the EX stage against the destination addresses of instructions in later stages. Forwarding only occurs if:
- The source register address is non-zero (as `x0` is hardwired to zero and never forwarded).
- The instruction in the later stage is actually scheduled to write to a register (`reg_we` is high).

### 2. Priority Logic (MEM over WB)
In the event of a "double hazard" (where both MEM and WB stages are writing to the same register required by EX), the **MEM stage takes priority**. This ensures the EX stage receives the *most recent* architectural state.

### 3. Multiplexer Control
The outputs `fwd_a_o` and `fwd_b_o` drive the 3-to-1 multiplexers at the ALU inputs.
- **Example for rs1:** If `(reg_we_mem_i && rd_addr_mem_i != 0 && rd_addr_mem_i == rs1_addr_ex_i)`, then `fwd_a_o` = `FWD_MEM`.
- Else if `(reg_we_wb_i && rd_addr_wb_i != 0 && rd_addr_wb_i == rs1_addr_ex_i)`, then `fwd_a_o` = `FWD_WB`.
- Else, `fwd_a_o` = `FWD_ID_EX`.

### 4. Combinational Path
The FU must be strictly combinational to allow data to be bypassed within the same clock cycle, ensuring zero-cycle latency for arithmetic dependencies.