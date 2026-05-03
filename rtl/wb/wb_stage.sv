// =============================================================================
// Project:         riscv-core
// File:            wb_stage.sv
//
// Description:     The Write-Back Stage of the RISC-V pipeline. Selects the 
//                  final data for the Register File.
//
// Dependencies:    riscv_types_pkg.sv, wb_mux.sv
//
// License:         Apache-2.0
// =============================================================================
`ifndef WB_STAGE_SV
`define WB_STAGE_SV
`timescale 1ns / 1ps
`default_nettype none

module wb_stage
    import riscv_types_pkg::*;
(
    // Data Inputs
    input data_t alu_result_i,
    input data_t lsu_data_i,
    input data_t pc_plus_4_i,

    // Control Inputs
    input wb_sel_e wb_sel_i,
    input logic    reg_write_en_i,

    // Final Outputs to Register File
    output data_t wb_data_o,
    output logic  reg_write_en_o
);

    // -------------------------------------------------------------------------
    // WB Mux Instantiation
    // -------------------------------------------------------------------------
    wb_mux u_wb_mux (
        .alu_result_i(alu_result_i),
        .lsu_data_i  (lsu_data_i),
        .pc_plus_4_i (pc_plus_4_i),
        .wb_sel_i    (wb_sel_i),
        .wb_data_o   (wb_data_o)
    );

    // Write enable is a direct pass-through to the RF in this stage
    assign reg_write_en_o = reg_write_en_i;

endmodule : wb_stage
`endif
