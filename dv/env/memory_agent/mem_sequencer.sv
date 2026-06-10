// =============================================================================
// Project:         riscv-core
// File:            mem_sequencer.sv
//
// Description:     UVM Sequencer routing randomized riscv_instr_tx transactions
//                  from verification sequences down to the memory driver.
//
// Dependencies:    riscv_types_pkg.sv, riscv_instr_tx.sv
//
// License:         Apache-2.0
// =============================================================================

`ifndef MEM_SEQUENCER_SV
`define MEM_SEQUENCER_SV

import uvm_pkg::*;
import core_env_pkg::*;
import riscv_types_pkg::*;

class mem_sequencer extends uvm_sequencer #(riscv_instr_tx);

    `uvm_component_utils(mem_sequencer)

    // --- Constructor ---
    function new(string name = "mem_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

endclass : mem_sequencer

`endif  // MEM_SEQUENCER_SV
