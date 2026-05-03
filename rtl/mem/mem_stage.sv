// =============================================================================
// Project:         riscv-core
// File:            mem_stage.sv
//
// Description:     The Memory Stage of the RISC-V pipeline. Orchestrates 
//                  data memory access via the LSU and prepares data for 
//                  the Write-Back stage.
//
// Dependencies:    riscv_types_pkg.sv, lsu.sv
//
// License:         Apache-2.0
// =============================================================================
`ifndef MEM_STAGE_SV
`define MEM_STAGE_SV
`timescale 1ns / 1ps
`default_nettype none

module mem_stage
    import riscv_types_pkg::*;
(
    // Control Signals
    input lsu_op_e lsu_op_i,
    input wb_sel_e wb_sel_i,
    input logic    mem_write_i,
    input logic    reg_write_en_i,

    // Data Signals from EX Stage
    input data_t alu_result_i,
    input data_t rs2_data_i,
    input data_t pc_plus_4_i,

    // Data Memory Interface (External)
    input  data_t         mem_rdata_i,
    output data_t         mem_wdata_o,
    output data_t         mem_addr_o,
    output bytes_enable_t mem_be_o,
    output logic          mem_we_o,

    // Signals to WB Stage
    output data_t   wb_alu_result_o,
    output data_t   wb_lsu_data_o,
    output data_t   wb_pc_plus_4_o,
    output wb_sel_e wb_sel_o,
    output logic    reg_write_en_o
);

    // -------------------------------------------------------------------------
    // Signal Pass-through (To be registered in a pipelined design)
    // -------------------------------------------------------------------------
    assign wb_alu_result_o = alu_result_i;
    assign wb_pc_plus_4_o  = pc_plus_4_i;
    assign wb_sel_o        = wb_sel_i;
    assign reg_write_en_o  = reg_write_en_i;

    // -------------------------------------------------------------------------
    // Load-Store Unit Instantiation
    // -------------------------------------------------------------------------
    lsu u_lsu (
        .lsu_op_i   (lsu_op_i),
        .addr_i     (alu_result_i),
        .wdata_i    (rs2_data_i),
        .mem_rdata_i(mem_rdata_i),
        .mem_write_i(mem_write_i),
        .mem_wdata_o(mem_wdata_o),
        .mem_be_o   (mem_be_o),
        .lsu_rdata_o(wb_lsu_data_o)
    );

    // The ALU result is used directly as the memory address
    assign mem_addr_o = alu_result_i;
    assign mem_we_o   = mem_write_i;

endmodule : mem_stage
`endif
