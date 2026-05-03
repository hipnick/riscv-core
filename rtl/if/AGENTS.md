# Instruction Fetch (IF) Stage

## Overview
The **Instruction Fetch (IF) Stage** is the first stage of the RISC-V processor pipeline. Its primary responsibility is to determine the next address to fetch from the Instruction Memory (IMEM) and manage speculative execution via branch prediction.

## 1. Architectural Components
The IF stage is composed of the following primary sub-modules:

1. **Program Counter (PC) Register**: A 32-bit register that holds the address of the current instruction being fetched.
2. **PC Incrementer**: Combinational logic that calculates `PC + 4` for sequential execution.
3. **Branch Target Buffer (BTB)**: A local cache used to predict the next PC for branch and jump instructions before they are decoded.
4. **Fetch Multiplexer**: Logic that selects the next PC source based on stalls, branch mispredictions (from the Execute stage), or BTB hits.

## 2. Interface Definition

### Input Signals
| Signal | Type | Source Stage | Description |
| :--- | :--- | :--- | :--- |
| `clk` | logic | System | Global Clock signal. |
| `rst_n` | logic | System | Active-low Asynchronous Reset. |
| `stall_i` | logic | Hazard Unit | Freezes the PC and IF/ID register on data/resource hazards. |
| `flush_i` | logic | Hazard Unit | Clears the IF/ID register (injects NOP) on branch mispredictions. |
| `ex_mispredict_i` | logic | Execute | High when the actual branch outcome differs from the prediction. |
| `ex_pc_corr_i` | data_t | Execute | The correct target address calculated by the ALU/Branch Unit. |
| `imem_instr_i` | data_t | IMEM | The 32-bit raw instruction fetched from memory. |

### Output Signals
| Signal | Type | Destination | Description |
| :--- | :--- | :--- | :--- |
| `imem_addr_o` | data_t | IMEM | The current Program Counter (PC) address sent to memory. |
| `id_instr_o` | data_t | ID Stage | The instruction bits passed to the Decoder. |
| `id_pc_o` | data_t | ID Stage | The PC associated with the instruction currently in the Decode stage. |

## 3. Functional Logic
The stage operates on every rising clock edge (`posedge clk`). The next PC value is determined by a priority-based selection:

1. **Trap/Exception**: Highest priority; jumps to a fixed vector address (if implemented).
2. **Execute Stage Correction**: If a branch was mispredicted, the pipeline is flushed and the PC is corrected to the "True" target.
3. **BTB Hit**: If the BTB predicts a branch at the current PC, the predicted target is used immediately to minimize bubbles.
4. **Sequential Fetch**: Default behavior; `PC = PC + 4`.