// =============================================================================
// Project:         riscv-core
// File:            test_hazards.sv
//
// Description:     Phase 2 Pipeline Hazard Stress Test Case. Iterates through 
//                  targeted hazard scenarios (RAW, Load-Use, Control Flow) and
//                  validates that structural stalls and bypasses clear cleanly.
//
// Dependencies:    riscv_types_pkg.sv, core_base_test.sv
//
// License:         Apache-2.0
// =============================================================================
`ifndef TEST_HAZARDS_SV
`define TEST_HAZARDS_SV

class test_hazards extends core_base_test;

    `uvm_component_utils(test_hazards)

    // Standard UVM Constructor
    function new(string name = "test_hazards", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    // UVM Build Phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase

    // UVM Run Phase: Control simulation lifecycle execution
    virtual task run_phase(uvm_phase phase);
        string target_payload = "hazard_raw.mem"; // Default starting point
        phase.raise_objection(this, "Starting Phase 2 Pipeline Hazard Execution");

        // Parse command line plusargs to choose which specific hazard type to load
        if ($value$plusargs("HAZARD_TYPE=%s", target_payload)) begin
            `uvm_info("TEST_HAZARDS", $sformatf("Hazard target selection detected: %s", target_payload), UVM_LOW)
        end else begin
            `uvm_warning("TEST_HAZARDS_DEFAULT", "No +HAZARD_TYPE specified. Running default RAW bypass tracking loop.")
        end

        `uvm_info("TEST_HAZARDS", $sformatf("Loading backdoor executable payload: %s", target_payload), UVM_LOW)
        
        // Inject selected binary into the behavioral memory array
        if (env.agent != null && env.agent.driver != null) begin
            env.agent.driver.load_backdoor_program(target_payload);
        end else begin
            `uvm_fatal("TEST_HAZARDS_INIT_FAIL", "Unable to access structural mem_driver handle for payload injection")
        end

        // Simulation runtime window to allow the pipeline hazards to execute, resolve, and flush
        #400ns;

        `uvm_info("TEST_HAZARDS", "Completing Phase 2 Pipeline Hazard Execution", UVM_LOW)
        phase.drop_objection(this, "Ending Phase 2 Pipeline Hazard Execution");
    endtask : run_phase

endclass : test_hazards

`endif // TEST_HAZARDS_SV