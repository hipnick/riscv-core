// =============================================================================
// Project:         riscv-core
// File:            pr_id_ex.sv
//
// Description:     Pipeline Register: Instruction Decode to Execute.
//
// =============================================================================
`ifndef PR_ID_EX_SV
`define PR_ID_EX_SV
`timescale 1ns / 1ps
`default_nettype none

module pr_id_ex
    import riscv_types_pkg::*;
(
    input logic clk_i,
    input logic rst_ni,
    input logic stall_i,
    input logic flush_i,

    // Control & Data from ID
    input data_t     pc_i,
    input data_t     reg_data1_i,
    input data_t     reg_data2_i,
    input data_t     imm_i,
    input alu_ctrl_e alu_op_i,
    input address_t  rd_addr_i,
    input logic      reg_write_en_i,
    input logic      mem_to_reg_i,

    // Outputs to EX
    output data_t     pc_o,
    output data_t     reg_data1_o,
    output data_t     reg_data2_o,
    output data_t     imm_o,
    output alu_ctrl_e alu_op_o,
    output address_t  rd_addr_o,
    output logic      reg_write_en_o,
    output logic      mem_to_reg_o
);

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pc_o           <= '0;
            reg_data1_o    <= '0;
            reg_data2_o    <= '0;
            imm_o          <= '0;
            alu_op_o       <= ALU_ADD;
            rd_addr_o      <= REG_ZERO;
            reg_write_en_o <= 1'b0;
            mem_to_reg_o   <= 1'b0;
        end else if (flush_i) begin
            pc_o           <= '0;
            reg_data1_o    <= '0;
            reg_data2_o    <= '0;
            imm_o          <= '0;
            alu_op_o       <= ALU_ADD;
            rd_addr_o      <= REG_ZERO;
            reg_write_en_o <= 1'b0;
            mem_to_reg_o   <= 1'b0;
        end else if (!stall_i) begin
            pc_o           <= pc_i;
            reg_data1_o    <= reg_data1_i;
            reg_data2_o    <= reg_data2_i;
            imm_o          <= imm_i;
            alu_op_o       <= alu_op_i;
            rd_addr_o      <= rd_addr_i;
            reg_write_en_o <= reg_write_en_i;
            mem_to_reg_o   <= mem_to_reg_i;
        end
    end

endmodule : pr_id_ex
`endif
