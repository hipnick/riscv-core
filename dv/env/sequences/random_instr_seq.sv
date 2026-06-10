// =============================================================================
// Project:         riscv-core
// File:            random_instr_seq.sv
//
// Description:     Phase 4 Constrained Random Sequence. Generates streams of
//                  unscripted instructions targeting structural corner cases.
//
// Dependencies:    riscv_types_pkg.sv, core_base_seq.sv
//
// License:         Apache-2.0
// =============================================================================
`ifndef RANDOM_INSTR_SEQ_SV
`define RANDOM_INSTR_SEQ_SV

import uvm_pkg::*;
import core_env_pkg::*;
import riscv_types_pkg::*;

class random_instr_seq extends core_base_seq;

    `uvm_object_utils(random_instr_seq)

    // Dynamic constraint tracking variables
    rand int unsigned num_instructions = 10000;

    constraint c_num_instrs {
        num_instructions inside {[5000:15000]};
    }

    // Standard UVM Constructor
    function new(string name = "random_instr_seq");
        super.new(name);
    endfunction : new

    // Primary Loop Generator Execution Block
    virtual task body();
        riscv_instr_tx tx;
        `uvm_info("RAND_SEQ", $sformatf("Initializing generation of %0d randomized transactions", num_instructions), UVM_LOW)

        for (int i = 0; i < num_instructions; i++) begin
            tx = riscv_instr_tx::type_id::create("tx");
            
            start_item(tx);
            if (!tx.randomize()) begin
                `uvm_fatal("RAND_SEQ_FAIL", "Catastrophic randomization constraint conflict broken in item loop")
            end
            finish_item(tx);
        end

        `uvm_info("RAND_SEQ", "Completed all transaction sequence streams successfully", UVM_LOW)
    endtask : body

endclass : random_instr_seq

`endif // RANDOM_INSTR_SEQ_SV