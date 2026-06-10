// =============================================================================
// Project:         riscv-core
// File:            test_smoke.sv
//
// Description:     Phase 1 Directed Assembly Smoke Test. Executes straight-line
//                  instructions without structural dependencies or hazards.
//
// Dependencies:    riscv_types_pkg.sv, core_base_test.sv
//
// License:         Apache-2.0
// =============================================================================
`ifndef TEST_SMOKE_SV
`define TEST_SMOKE_SV

class test_smoke extends core_base_test;

    `uvm_component_utils(test_smoke)

    // Standard UVM Constructor
    function new(string name = "test_smoke", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    // UVM Build Phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase

    // UVM Run Phase: Control simulation lifecycle execution
    virtual task run_phase(uvm_phase phase);
        string mem_file = "smoke.mem"; // Default fallback configuration
        phase.raise_objection(this, "Starting Phase 1 Smoke Test Execution");

        // Retrieve runtime parameter selection from the execution command line
        if ($value$plusargs("MEM_FILE=%s", mem_file)) begin
            `uvm_info("TEST_SMOKE", $sformatf("Command line override detected. Loading: %s", mem_file), UVM_LOW)
        end

        if (env.agent != null && env.agent.driver != null) begin
            env.agent.driver.load_backdoor_program(mem_file);
        end else begin
            `uvm_fatal("TEST_SMOKE_INIT_FAIL", "Unable to access structural mem_driver handle")
        end

        #500ns; // Extended simulation budget window to accommodate the larger program sequence

        phase.drop_objection(this, "Ending Phase 1 Smoke Test Execution");
    endtask : run_phase

endclass : test_smoke

`endif // TEST_SMOKE_SV