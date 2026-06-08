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
`ifndef TEST_C_RUNTIME_SV
`define TEST_C_RUNTIME_SV

class test_c_runtime extends core_base_test;

    `uvm_component_utils(test_c_runtime)

    // Standard UVM Constructor
    function new(string name = "test_c_runtime", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    // UVM Build Phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase

    // UVM Run Phase: Control simulation lifecycle execution
    virtual task run_phase(uvm_phase phase);
        string mem_file = "c_runtime.mem"; // Default fallback configuration
        phase.raise_objection(this, "Starting Phase 1 C Runtime Test Execution");

        // Retrieve runtime parameter selection from the execution command line
        if ($value$plusargs("MEM_FILE=%s", mem_file)) begin
            `uvm_info("TEST_C_RUNTIME", $sformatf("Command line override detected. Loading: %s", mem_file), UVM_LOW)
        end

        if (env.imem_dmem_agent != null && env.imem_dmem_agent.mem_driver != null) begin
            env.imem_dmem_agent.mem_driver.load_backdoor_program(mem_file);
        end else begin
            `uvm_fatal("TEST_C_RUNTIME_INIT_FAIL", "Unable to access structural mem_driver handle")
        end

        #500ns; // Extended simulation budget window to accommodate the larger program sequence

        phase.drop_objection(this, "Ending Phase 1 C Runtime Test Execution");
    endtask : run_phase

endclass : test_smoke

`endif // TEST_C_RUNTIME_SV