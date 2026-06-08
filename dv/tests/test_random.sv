// =============================================================================
// Project:         riscv-core
// File:            test_random.sv
//
// Description:     Phase 4 Test Case wrapper executing the unscripted random
//                  instruction generator sequence stream.
//
// Dependencies:    riscv_types_pkg.sv, core_base_test.sv, random_instr_seq.sv
//
// License:         Apache-2.0
// =============================================================================
`ifndef TEST_RANDOM_SV
`define TEST_RANDOM_SV

class test_random extends core_base_test;

    `uvm_component_utils(test_random)

    // Handle to random instruction stream sequence
    random_instr_seq rand_seq;

    // Standard UVM Constructor
    function new(string name = "test_random", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    // UVM Build Phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rand_seq = random_instr_seq::type_id::create("rand_seq");
    endfunction : build_phase

    // UVM Run Phase: Drive sequence down onto active agent sequencer loops
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this, "Starting Phase 4 Constrained Random Execution");

        // Instruct active memory agent sequencer to consume the randomized sequence loop
        if (env.imem_dmem_agent != null && env.imem_dmem_agent.mem_sequencer != null) begin
            rand_seq.start(env.imem_dmem_agent.mem_sequencer);
        end else begin
            `uvm_fatal("TEST_RAND_INIT_FAIL", "Unable to locate environment target virtual sequencer hook")
        end

        phase.drop_objection(this, "Ending Phase 4 Constrained Random Execution");
    endtask : run_phase

endclass : test_random

`endif // TEST_RANDOM_SV