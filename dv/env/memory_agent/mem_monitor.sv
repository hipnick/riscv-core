// =============================================================================
// Project:         riscv-core
// File:            mem_monitor.sv
//
// Description:     Passive UVM monitor that samples pin-level bus activity 
//                  from core_if using the monitor clocking block (mon_cb)
//                  and writes collected transactions to an analysis port.
//
// Dependencies:    riscv_types_pkg.sv, riscv_instr_tx.sv, core_if.sv
//
// License:         Apache-2.0
// =============================================================================

`ifndef MEM_MONITOR_SV
`define MEM_MONITOR_SV

import uvm_pkg::*;
import core_env_pkg::*;
import riscv_types_pkg::*;

class mem_monitor extends uvm_monitor;

    `uvm_component_utils(mem_monitor)

    // Virtual Interface handle to sample pins via modport clocking block
    virtual core_if.monitor vif;

    // Analysis Port to broadcast decoded execution packets to the scoreboard
    uvm_analysis_port #(riscv_instr_tx) ap;

    // --- Constructor ---
    function new(string name = "mem_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction : new

    // --- Build Phase ---
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual core_if.monitor)::get(
                this, "", "vif", vif
            )) begin
            `uvm_fatal("NOVIF", {"Virtual interface modport must be set for: ",
                                 get_full_name(), ".vif"})
        end
    endfunction : build_phase

    // --- Run Phase ---
    virtual task run_phase(uvm_phase phase);
        // Block processing until system reset is completely de-asserted
        wait (vif.rst_n == 1'b1);

        forever begin
            collect_transaction();
        end
    endtask : run_phase

    // --- Core Sampling Loop ---
    protected task collect_transaction();
        riscv_instr_tx tx;
        data_t         sampled_instr;
        imm_src_e      imm_type;

        // Synchronize on the monitor clocking block event edge
        @(vif.mon_cb);

        // Sample synchronously using the input skew defined in mon_cb
        if (vif.mon_cb.imem_valid) begin
            tx            = riscv_instr_tx::type_id::create("tx");
            sampled_instr = vif.mon_cb.imem_rdata;

            // Capture raw bus state and map directly to transaction properties
            tx.opcode     = opcode_e'(sampled_instr[6:0]);
            tx.funct3     = funct3_e'(sampled_instr[14:12]);
            tx.funct7     = funct7_e'(sampled_instr[31:25]);
            tx.rd         = sampled_instr[11:7];
            tx.rs1        = sampled_instr[19:15];
            tx.rs2        = sampled_instr[24:20];

            // Reconstruct the sign-extended immediate value based on transaction type
            imm_type      = get_imm_type(tx.opcode);
            tx.imm        = decode_immediate(sampled_instr, imm_type);

            // Broadcast to the scoreboard via TLM analysis port
            ap.write(tx);
        end
    endtask : collect_transaction

    // --- Helper Functions for Field Reconstruction ---
    protected function imm_src_e get_imm_type(opcode_e op);
        case (op)
            OP_I_TYPE, OP_LOAD, OP_JALR: return IMM_I;
            OP_STORE:                    return IMM_S;
            OP_BRANCH:                   return IMM_B;
            OP_LUI, OP_AUIPC:            return IMM_U;
            OP_JAL:                      return IMM_J;
            default:                     return IMM_I;
        endcase
    endfunction : get_imm_type

    protected function data_t decode_immediate(logic [31:0] instr,
                                               imm_src_e kind);
        data_t decoded_imm;
        case (kind)
            IMM_I: decoded_imm = {{REP_I{instr[SIGN_BIT]}}, instr[31:20]};
            IMM_S:
            decoded_imm = {{REP_S{instr[SIGN_BIT]}}, instr[31:25], instr[11:7]};
            IMM_B:
            decoded_imm = {
                {REP_B{instr[SIGN_BIT]}},
                instr[7],
                instr[30:25],
                instr[11:8],
                1'b0
            };
            IMM_U: decoded_imm = {instr[31:12], 12'b0};
            IMM_J:
            decoded_imm = {
                {REP_J{instr[SIGN_BIT]}},
                instr[19:12],
                instr[20],
                instr[30:21],
                1'b0
            };
            default: decoded_imm = '0;
        endcase
        return decoded_imm;
    endfunction : decode_immediate

endclass : mem_monitor

`endif  // MEM_MONITOR_SV
