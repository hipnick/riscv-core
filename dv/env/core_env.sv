// =============================================================================
// Project:         riscv-core
// File:            core_env.sv
//
// Description:     UVM Environment class that instantiates and connects the
//                  imem/dmem agent and scoreboard for the RISC-V core.
// =============================================================================

`ifndef CORE_ENV_SV
`define CORE_ENV_SV

import uvm_pkg::*;
import riscv_types_pkg::*;

class core_env extends uvm_env;

    `uvm_component_utils(core_env)

    // Agent: drives and monitors instruction/data memory buses
    imem_dmem_agent agent;
    core_scoreboard scoreboard;

    function new(string name = "core_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent     = new("agent", this);
        scoreboard = new("scoreboard", this);
    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.ap.connect(scoreboard.item_collected_imp);
    endfunction : connect_phase

endclass : core_env

`endif // CORE_ENV_SV
