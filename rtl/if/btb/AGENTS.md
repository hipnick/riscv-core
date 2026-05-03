# Branch Target Buffer (BTB)

## Overview
The **Branch Target Buffer (BTB)** is a specialized cache used in the **Instruction Fetch (IF)** stage to predict the destination of branch instructions before they are even decoded. By "remembering" previous jump targets, the hardware can speculatively fetch the next instruction stream, significantly reducing pipeline stalls or "bubbles".

## Theory of Operation
1.  **Look-up**: Every time a Program Counter (PC) is generated, the BTB is indexed using a portion of that PC.
2.  **Hit/Miss**: If the PC exists in the BTB (a "Hit"), the module provides a predicted target address.
3.  **Update**: Once a branch is actually resolved (Execute stage), the BTB is updated with the actual outcome and final target address to improve future accuracy.

## Technical Specifications
| Feature | Implementation |
| :--- | :--- |
| **Storage Type** | Content Addressable Memory (CAM) or Tagged RAM |
| **Key (Tag)** | Program Counter (PC) of the branch instruction |
| **Value (Data)** | Predicted Target Address |
| **Prediction Logic** | 1-bit or 2-bit saturating counter (Taken/Not-Taken) |

## Interface Definition

| Signal Name | Type | Direction | Description |
| :--- | :--- | :--- | :--- |
| `clk_i` | `logic` | Input | System Clock |
| `rst_ni` | `logic` | Input | Active-low Asynchronous Reset |
| `pc_if_i` | `data_t` | Input | Current PC from the Fetch stage for look-up |
| `update_i` | `logic` | Input | Control signal from Execute stage to update the buffer |
| `actual_pc_i` | `data_t` | Input | The PC of the branch being resolved |
| `actual_target_i` | `data_t` | Input | The actual resolved target address |
| `predict_target_o`| `data_t` | Output | The cached target address for speculative fetch |
| `hit_o` | `logic` | Output | High if the current PC is found in the buffer |

## Design Rules
- **Cycle-Accuracy**: The look-up must happen within the Fetch cycle to avoid introducing latency.
- **Collision Handling**: Since the BTB is a finite size, a replacement policy (like LRU) must be considered for when the buffer is full.
- **Reset State**: On reset, all valid bits must be cleared to prevent speculative jumps to "garbage" addresses.