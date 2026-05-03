# MEM Stage Documentation

## Overview
The Memory (MEM) Stage orchestrates data movement between the CPU pipeline and external Data Memory. It integrates the Load-Store Unit (LSU) to handle architectural requirements such as sign-extension and byte-alignment while driving the Data Memory (DMEM) Interface.

## Input/Output Ports
| Name | Direction | Type | Description |
|:---|:---|:---|:---|
| **lsu_op_i** | Input | lsu_op_e | Specifies access width (Byte, Half, Word) and extension type. |
| **wb_sel_i** | Input | wb_sel_e | Steering signal for the final Write-Back multiplexer. |
| **mem_write_i** | Input | logic | Master write enable for Data Memory operations. |
| **reg_write_en_i** | Input | logic | Pass-through enable for the Register File write port. |
| **alu_result_i** | Input | data_t | Calculated effective address or arithmetic result. |
| **mem_wdata_i** | Input | data_t | Store data originating from the register file (rs2). |
| **pc_plus_4_i** | Input | data_t | Sequential return address for Jump-and-Link operations. |
| **mem_rdata_i** | Input | data_t | Raw 32-bit word received from external Data Memory. |
| **mem_wdata_o** | Output | data_t | Aligned and masked data driven to the Memory Bus. |
| **mem_addr_o** | Output | data_t | Effective address driven to the Memory Bus. |
| **mem_be_o** | Output | logic [3:0] | Byte-enable strobes for partial-word writes. |
| **mem_we_o** | Output | logic | External memory write strobe. |
| **wb_alu_result_o** | Output | data_t | ALU result passed to the WB stage. |
| **wb_lsu_data_o** | Output | data_t | Aligned/Extended load data passed to the WB stage. |
| **wb_pc_plus_4_o** | Output | data_t | PC+4 passed to the WB stage. |
| **wb_sel_o** | Output | wb_sel_e | Mux select signal passed to the WB stage. |
| **reg_write_en_o** | Output | logic | Final write enable passed to the WB stage. |