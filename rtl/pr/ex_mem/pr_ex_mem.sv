// =============================================================================
// Project:         riscv-core
// File:            pr_ex_mem.sv
//
// Description:     Pipeline Register: Execute to Memory.
//
// =============================================================================
`ifndef PR_EX_MEM_SV
`define PR_EX_MEM_SV
`timescale 1ns / 1ps
`default_nettype none

module pr_ex_mem
    import riscv_types_pkg::*;
(
    input logic clk_i,
    input logic rst_ni,
    input logic stall_i,

    // Data from EX
    input data_t    alu_result_i,
    input data_t    reg_data2_i,
    input address_t rd_addr_i,
    input logic     reg_write_en_i,
    input logic     mem_to_reg_i,

    // Outputs to MEM
    output data_t    alu_result_o,
    output data_t    reg_data2_o,
    output address_t rd_addr_o,
    output logic     reg_write_en_o,
    output logic     mem_to_reg_o
);

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            alu_result_o   <= '0;
            reg_data2_o    <= '0;
            rd_addr_o      <= REG_ZERO;
            reg_write_en_o <= 1'b0;
            mem_to_reg_o   <= 1'b0;
        end else if (!stall_i) begin
            alu_result_o   <= alu_result_i;
            reg_data2_o    <= reg_data2_i;
            rd_addr_o      <= rd_addr_i;
            reg_write_en_o <= reg_write_en_i;
            mem_to_reg_o   <= mem_to_reg_i;
        end
    end

endmodule : pr_ex_mem
`endif
