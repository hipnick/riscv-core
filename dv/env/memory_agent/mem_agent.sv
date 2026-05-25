// =============================================================================
// Project:         riscv-core
// File:            mem_agent.sv
//
// Description:     Active UVM Agent encapsulating the sequencer, driver, 
//                  and monitor for the RISC-V memory bus interfaces.
//
// Dependencies:    riscv_types_pkg.sv, core_env_pkg.sv
//
// License:         Apache-2.0
// =============================================================================

`ifndef MEM_AGENT_SV
`define MEM_AGENT_SV

import riscv_types_pkg::*;
import core_env_pkg::*;

class mem_agent extends uvm_agent;

    `uvm_component_utils(mem_agent)

    // --- Sub-Components ---
    mem_sequencer sequencer;
    mem_driver    driver;
    mem_monitor   monitor;

    // --- Analysis Port for Environment Connectivity ---
    uvm_analysis_port #(riscv_instr_tx) ap;

    // --- Constructor ---
    function new(string name = "mem_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    // --- Build Phase ---
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Always build the passive observer monitor
        monitor = mem_monitor::type_id::create("monitor", this);
        ap      = new("ap", this);

        // Build driving paths only if the agent is configured as ACTIVE
        if (get_is_active() == UVM_ACTIVE) begin
            sequencer = mem_sequencer::type_id::create("sequencer", this);
            driver    = mem_driver::type_id::create("driver", this);
        end
    endfunction : build_phase

    // --- Connect Phase ---
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Route the monitor's telemetry port up to the agent's external port boundary
        monitor.ap.connect(this.ap);

        // Internal plumbing hookup: connect the sequencer transaction streams to the driver input ports
        if (get_is_active() == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction : connect_phase

endclass : mem_agent

`endif  // MEM_AGENT_SV
