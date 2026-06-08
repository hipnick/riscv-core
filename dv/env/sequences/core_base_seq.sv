// =============================================================================
// Project:         riscv-core
// File:            core_base_seq.sv
//
// Description:     Parent base sequence object that orchestrates execution loops.
//
// Dependencies:    riscv_types_pkg.sv, riscv_instr_tx.sv
//
// License:         Apache-2.0
// =============================================================================
`ifndef CORE_BASE_SEQ_SV
`define CORE_BASE_SEQ_SV

class core_base_seq extends uvm_sequence #(riscv_instr_tx);

    `uvm_object_utils(core_base_seq)

    // Standard UVM Constructor
    function new(string name = "core_base_seq");
        super.new(name);
    endfunction : new

    // Standard body virtualization task
    virtual task body();
        `uvm_info("BASE_SEQ", "Executing base instruction pipeline sequence path", UVM_HIGH)
    endtask : body

endclass : core_base_seq

`endif // CORE_BASE_SEQ_SV