// =============================================================================
// Project:         riscv-core
// File:            pr_if_id.sv
//
// Description:     Pipeline Register: Instruction Fetch to Instruction Decode.
//
// =============================================================================
`ifndef PR_IF_ID_SV
`define PR_IF_ID_SV
`timescale 1ns / 1ps
`default_nettype none

module pr_if_id
    import riscv_types_pkg::*;
(
    input logic clk_i,
    input logic rst_ni,
    input logic stall_i,
    input logic flush_i,

    // Inputs from IF
    input data_t pc_i,
    input data_t instr_i,

    // Outputs to ID
    output data_t pc_o,
    output data_t instr_o
);

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pc_o    <= '0;
            instr_o <= '0;
        end else if (flush_i) begin
            pc_o    <= '0;
            instr_o <= '0;
        end else if (!stall_i) begin
            pc_o    <= pc_i;
            instr_o <= instr_i;
        end
    end

endmodule : pr_if_id
`endif
