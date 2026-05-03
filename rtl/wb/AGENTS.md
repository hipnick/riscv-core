# WB Stage Documentation

## Overview
The WB (Write-Back) Stage is the terminal stage of the processor pipeline. It accepts candidate data from the Execution and Memory stages and uses the `wb_mux` to determine which value is committed to the architectural state (the Register File).

## Input/Output Ports
| Name | Direction | Type | Description |
|:---|:---|:---|:---|
| **alu_result_i** | Input | data_t | Computational result from the ALU. |
| **lsu_data_i** | Input | data_t | Aligned load data from the MEM stage. |
| **pc_plus_4_i** | Input | data_t | Return address for jump/link instructions. |
| **wb_sel_i** | Input | wb_sel_e | Selects the source for the Write-Back data. |
| **reg_write_en_i** | Input | logic | Write enable signal for the Register File. |
| **wb_data_o** | Output | data_t | Final 32-bit data to be written to register `rd`. |
| **reg_write_en_o** | Output | logic | Final write enable strobe for the Register File. |
