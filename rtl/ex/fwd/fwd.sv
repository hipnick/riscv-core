// =============================================================================
// Project:         riscv-core
// File:            fwd.sv
//
// Description:     Forwarding Unit (FWD) to resolve RAW data hazards.
//                  Implements priority logic for MEM and WB stages.
//
// Dependencies:    riscv_types_pkg.sv
//
// License:         Apache-2.0
// =============================================================================
`ifndef FWD_SV
`define FWD_SV
`timescale 1ns / 1ps
`default_nettype none

module fwd
    import riscv_types_pkg::*;
(
    // Inputs from EX stage
    input  address_t  op_a_addr_i,
    input  address_t  op_b_addr_i,
    // Inputs from MEM stage
    input  address_t  rd_addr_mem_i,
    input  logic      reg_we_mem_i,
    // Inputs from WB stage
    input  address_t  rd_addr_wb_i,
    input  logic      reg_we_wb_i,
    // Control outputs for ALU muxes
    output fwd_ctrl_e fwd_a_o,
    output fwd_ctrl_e fwd_b_o
);

    /**
     * compute_fwd_ctrl: Encapsulates the priority mux logic for a single operand.
     * Higher priority is given to the MEM stage (most recent data).
     */
    function automatic fwd_ctrl_e compute_fwd_ctrl(
        input address_t op_addr, input address_t rd_addr_mem,
        input logic reg_we_mem, input address_t rd_addr_wb,
        input logic reg_we_wb);
        // Default: Use data from Register File (ID/EX)
        fwd_ctrl_e sel;
        sel = FWD_ID_EX;

        // Priority 2: WB Hazard
        // If the instruction in WB writes to the current operand register
        if (reg_we_wb && (rd_addr_wb != REG_ZERO) && (rd_addr_wb == op_addr)) begin
            sel = FWD_WB;
        end

        // Priority 1: MEM Hazard (Overrides WB)
        // If the instruction in MEM writes to the current operand register
        if (reg_we_mem && (rd_addr_mem != REG_ZERO) && (rd_addr_mem == op_addr)) begin
            sel = FWD_MEM;
        end

        return sel;
    endfunction

    //--------------------------------------------------------------------------
    // Forwarding Logic for Operand A (rs1)
    //--------------------------------------------------------------------------
    assign fwd_a_o = compute_fwd_ctrl(
        op_a_addr_i, rd_addr_mem_i, reg_we_mem_i, rd_addr_wb_i, reg_we_wb_i
    );

    //--------------------------------------------------------------------------
    // Forwarding Logic for Operand B (rs2)
    //--------------------------------------------------------------------------
    // Operand B (rs2) Logic
    assign fwd_b_o = compute_fwd_ctrl(
        op_b_addr_i, rd_addr_mem_i, reg_we_mem_i, rd_addr_wb_i, reg_we_wb_i
    );

endmodule : fwd
`endif
