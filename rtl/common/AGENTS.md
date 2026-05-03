# Common RTL Components

This directory serves as the **Single Source of Truth** for the entire RISC-V core project. It contains globally shared packages, parameters, and utility modules that are utilized across multiple stages of the pipeline (Fetch, Decode, Execute, Memory, Writeback).

## 📌 Guiding Principles
1. **Global Configuration:** Parameters that define the "shape" of the processor (e.g., Data Width) must be defined here to ensure consistency.
2. **Type Safety:** All shared Enums and Structs should reside here to prevent "magic numbers" and port-mapping errors.
3. **Hardware-Software Contract**: This folder contains parameters that define the physical hardware (e.g., DATA_WIDTH). While the Verification (DV) environment will import these values to stay in sync with the RTL, this folder should not contain any code that is purely for simulation (like testbench delays or scoreboard logic).

---

## 📂 Current Files

### 1. `riscv_types_pkg.sv`
The primary global package for the core. 
- **Data Widths:** Defines the standard `DATA_WIDTH` (32-bit) and the calculated `DATA_WIDTH_BITS` for shifter indexing.
- **ALU Operations:** Contains the `alu_ctrl_e` enumerated type, ensuring that the **Instruction Decoder** and the **ALU** speak the same binary language.
- **Portability:** Centralizing these values allows the core to be scaled (e.g., from RV32I to RV64I) by modifying a single file.

---

## 🛠 Usage
To use the common types in any module, include the following statement at the top of your SystemVerilog file:

```systemverilog
import riscv_types_pkg::*;