// =============================================================================
// Project:         riscv-core
// File:            core_base_test.sv
//
// Description:     Parent base test component that instantiates and configures
//                  the core verification environment (core_env).
//
// Dependencies:    riscv_types_pkg.sv, core_env.sv
//
// License:         Apache-2.0
// =============================================================================
`ifndef CORE_BASE_TEST_SV
`define CORE_BASE_TEST_SV

import uvm_pkg::*;
import core_env_pkg::*;
import riscv_types_pkg::*;

class core_base_test extends uvm_test;

    `uvm_component_utils(core_base_test)

    // Environment handle container
    core_env env;

    // Standard UVM Constructor
    function new(string name = "core_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    // UVM Build Phase: Instantiate top-level environment configuration
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = core_env::type_id::create("env", this);
    endfunction : build_phase

    // UVM End of Elaboration Phase: Print structural topology for debug
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_root::get().print_topology();
    endfunction : end_of_elaboration_phase

endclass : core_base_test

`endif // CORE_BASE_TEST_SV