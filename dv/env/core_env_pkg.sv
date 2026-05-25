// =============================================================================
// Project:         riscv-core
// File:            core_env_pkg.sv
//
// Description:     Verification package bundling all UVM components, 
//                  sequences, and transaction types for the RISC-V environment.
//
// Dependencies:    riscv_types_pkg.sv
//
// License:         Apache-2.0
// =============================================================================

`ifndef CORE_ENV_PKG_SV
`define CORE_ENV_PKG_SV
`timescale 1ns / 1ps
`default_nettype none

package core_env_pkg;

    // --- Standard UVM Imports ---
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // --- RTL Types Import ---
    import riscv_types_pkg::*;

    // --- Component Includes (Strict Compilation Dependency Order) ---
    `include "riscv_instr_tx.sv"
    `include "mem_monitor.sv"
    `include "mem_driver.sv"
    // `include "mem_sequencer.sv"  // Uncomment when generated
    // `include "imem_dmem_agent.sv" // Uncomment when generated
    // `include "core_scoreboard.sv" // Uncomment when generated
    // `include "core_env.sv"        // Uncomment when generated

endpackage : core_env_pkg

`endif  // CORE_ENV_PKG_SV
