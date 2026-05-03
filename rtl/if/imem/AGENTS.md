# Instruction Memory (IMEM) Module

## Overview
The **Instruction Memory** is a read-only memory (ROM) structure that stores the executable machine code for the RISC-V core. It accepts a 32-bit address from the Program Counter (PC) and returns the corresponding 32-bit instruction during the Fetch (IF) stage.

## Signals

| Signal Name | Type      | Direction | Description |
| :---        | :---      | :---      | :---        |
| `addr_i`    | `data_t`  | Input     | The 32-bit address provided by the Program Counter. |
| `instr_o`   | `data_t`  | Output    | The 32-bit instruction fetched from the given address. |

## Theory of Operation
1. **Asynchronous Read**: In this implementation, the IMEM operates as combinational logic. When `addr_i` changes, `instr_o` updates immediately (after the gate delay).
2. **Word Alignment**: Since RISC-V instructions are 4 bytes wide, the memory is typically addressed using bits `[31:2]` of the address, as instructions are expected to be word-aligned.
3. **Storage**: During simulation, the memory is usually initialized via a hex file using the `$readmemh` system task.

## Implementation Rules
* **Strict Typing**: Uses `logic` for all internal signal definitions to prevent multi-driver contention.
* **No Write Port**: To maintain the "Read-Only" nature of instruction memory in a basic core, no write enable (`we_i`) or data input (`data_i`) signals are present.

