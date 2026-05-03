# Submodule: Register File (RF)

The **Register File** is a synchronous dual-port read, single-port write memory block containing 32 general-purpose registers (`x0` through `x31`). In the RISC-V ISA, register `x0` is physically hardwired to constant zero.

## 1. Interface Definition

### Input Signals
| Signal        | Type | Description                                           |
| :------------ | :---: | :---------------------------------------------------- |
| `clk_i`       |   1   | Global Clock signal.                                  |
| `rst_ni`      |   1   | Asynchronous Active-Low Reset.                        |
| `rs1_addr_i`  |  address_t| Source Register 1 address (Read Port 1).              |
| `rs2_addr_i`  |  address_t| Source Register 2 address (Read Port 2).              |
| `rd_addr_i`   |  address_t| Destination Register address (Write Port).            |
| `rd_data_i`   | data_t| Data to be written to the destination register.       |
| `rd_we_i`     |   1   | Write Enable. Data is written on `posedge` if high.   |

### Output Signals
| Signal        | Type | Description                                           |
| :------------ | :---: | :---------------------------------------------------- |
| `rs1_data_o`  | data_t| Data output from Read Port 1.                         |
| `rs2_data_o`  | data_t| Data output from Read Port 2.                         |

---

## 2. Functional Requirements
1.  **Hardwired Zero:** Any read to `rs1_addr_i == 5'b00000` or `rs2_addr_i == 5'b00000` must return `32'h00000000`, regardless of write operations.
2.  **Synchronous Write:** Data from `rd_data_i` is stored in the register specified by `rd_addr_i` only on the rising edge of `clk_i` when `rd_we_i` is asserted.
3.  **Asynchronous Read:** (Standard for many RISC-V designs) Register reads are combinational. As soon as the address is provided, the data should be available on the output ports (similar to a getter function).
4.  **Reset Behavior:** Upon `rst_ni` assertion, all registers (except `x0`) should ideally be cleared to zero to avoid `X` (unknown) states during simulation.

---
