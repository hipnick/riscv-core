// =============================================================================
// Project:         riscv-core
// File:            core_env_pkg.sv
//
// Description:     Verification package containing the riscv_instr_tx
//                  transaction object for the RISC-V core verification env.
//
// Dependencies:    riscv_types_pkg.sv, uvm_pkg
//
// License:         Apache-2.0
// =============================================================================

`ifndef CORE_ENV_PKG_SV
`define CORE_ENV_PKG_SV

package core_env_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import riscv_types_pkg::*;

    `include "riscv_instr_tx.sv"

endpackage : core_env_pkg

`endif  // CORE_ENV_PKG_SV
