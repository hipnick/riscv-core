# Program Counter (PC) Module

## Overview
The **Program Counter** is a 32-bit register that holds the memory address of the current instruction being fetched. It serves as the pointer to the Instruction Memory. In a standard RISC-V flow, it typically increments by 4 (bytes) every clock cycle, unless interrupted by branching logic.

## Signals

| Signal Name | Type | Direction | Description |
| :--- | :--- | :--- | :--- |
| `clk_i` | `logic` | Input | System clock (triggers update on rising edge). |
| `rst_ni` | `logic` | Input | Active-low asynchronous reset. Sets PC to boot address. |
| `pc_next_i` | `data_t` | Input | The next address calculated by the IF stage (PC+4 or Jump target). |
| `pc_o` | `data_t` | Output | The current instruction address sent to Instruction Memory. |

## Theory of Operation
1. **Reset State**: Upon `rst_ni` transitioning to `0`, the `pc_o` is immediately cleared to `0x00000000`.
2. **Synchronous Update**: On every `posedge clk`, the register captures the value present at `pc_next_i`.
3. **Flow Control**: The logic for whether to increment (PC + 4) or branch is handled outside this module; the PC simply acts as the "State" container.

## Implementation Rules
*   **Non-blocking Assignments**: Must use `<= (non-blocking)` to model synchronous flip-flop behavior.
*   **Active-Low Reset**: Standard practice for modern digital design to save power and improve noise immunity.