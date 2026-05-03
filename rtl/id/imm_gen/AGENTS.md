# Module Specification: Immediate Generator (imm_gen.sv)

## 1. Overview
The **Immediate Generator** is a combinational logic block responsible for extracting encoded immediate values from the instruction word and expanding them into a full `data_t` width. It reconstructs the "scrambled" bits defined by the RISC-V ISA into a standard two's complement integer.

## 2. Interface Definition

| Signal          | Direction | Type          | Description                                     |
| :-------------- | :-------- | :---------    | :---------------------------------------------- |
| `inst_i` | Input     | `data_t`      | Raw 32-bit machine code instruction.            |
| `imm_o`   | Output    | `data_t`      | Reassembled, sign-extended immediate value.     |

## 3. Functional Logic
The module uses a `case` statement based on the `opcode_e` to determine which bits to "swizzle." 

### 3.1 Constants and Indices
To avoid magic numbers, we utilize the following architectural rules:
* **MSB_BIT**: The most significant bit (Sign Bit) of every RISC-V immediate is always located at the highest index of the instruction word.
* **SIGN_EXT**: The MSB is replicated to fill all bits higher than the immediate's natural width to maintain signed integrity.
* **ZERO_FILL**: For specific types (like U-Type), the lower bits are filled with logic `0`.

### 3.2 Format Mapping Logic
* **I-Type**: Concatenates the upper bits of the instruction with the sign bit replication.
* **S-Type**: Combines two separate bit-fields from the instruction to form a contiguous 12-bit value before sign-extension.
* **B-Type**: Reorders bits to account for the implicit zero in the least significant bit of branch offsets.
* **U-Type**: Places the instruction bits into the upper portion of the `data_t` and clears the lower portion.
* **J-Type**: Reassembles a large scrambled immediate for long-distance jumps.

## 4. Design Rules
* **No Magic Numbers**: All widths and indices must be derived from the `data_t` definition or package-level constants.
* **Combinational Path**: Implemented using `always_comb` to ensure the value is available in the same cycle it is decoded.
* **Default State**: Any unrecognized opcode must result in `immediate_o` being driven to all zeros (`'0`) to prevent latch inference.