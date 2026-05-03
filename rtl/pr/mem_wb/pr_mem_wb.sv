// =============================================================================
// Project:         riscv-core
// File:            pr_mem_wb.sv
//
// Description:     Pipeline Register: Memory to Write Back.
//
// =============================================================================
`ifndef PR_MEM_WB_SV
`define PR_MEM_WB_SV
`timescale 1ns / 1ps
`default_nettype none

module pr_mem_wb
    import riscv_types_pkg::*;
(
    input logic clk_i,
    input logic rst_ni,
    input logic stall_i,

    // Data from MEM
    input data_t    alu_result_i,
    input data_t    mem_data_i,
    input address_t rd_addr_i,
    input logic     reg_write_en_i,
    input logic     mem_to_reg_i,

    // Outputs to WB
    output data_t    alu_result_o,
    output data_t    mem_data_o,
    output address_t rd_addr_o,
    output logic     reg_write_en_o,
    output logic     mem_to_reg_o
);

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            alu_result_o   <= '0;
            mem_data_o     <= '0;
            rd_addr_o      <= REG_ZERO;
            reg_write_en_o <= 1'b0;
            mem_to_reg_o   <= 1'b0;
        end else if (!stall_i) begin
            alu_result_o   <= alu_result_i;
            mem_data_o     <= mem_data_i;
            rd_addr_o      <= rd_addr_i;
            reg_write_en_o <= reg_write_en_i;
            mem_to_reg_o   <= mem_to_reg_i;
        end
    end

endmodule : pr_mem_wb
`endif
