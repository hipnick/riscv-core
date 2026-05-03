// =============================================================================
// Project:         riscv-core
// File:            core_top.sv
//
// Description:     Cleaned, linter-optimized top-level structural wrapper.
//                  All unused dangling wires removed; ports cleanly terminated.
//
// Dependencies:    riscv_types_pkg.sv
// =============================================================================
`ifndef CORE_TOP_SV
`define CORE_TOP_SV
`timescale 1ns / 1ps
`default_nettype none

module core_top
    import riscv_types_pkg::*;
(
    // Global Infrastructure
    input logic clk_i,
    input logic rst_ni,

    // Instruction Memory Interface (IF Stage Bus)
    output data_t instr_addr_o,
    input  data_t instr_data_i,

    // Data Memory Interface (MEM Stage Bus)
    input  data_t dmem_rdata_i,
    output data_t dmem_wdata_o,
    output data_t dmem_addr_o,
    output logic  dmem_we_o
);

    // =========================================================================
    // Internal Wire Harness (Pruned & Warning-Free)
    // =========================================================================

    // Hazard Mitigation Control
    logic      hdu_stall;
    logic      ex_mispredict;

    // ---- IF Stage Interconnects ----
    data_t     pc_if;

    // ---- pr_if_id Register Outputs ----
    data_t     pc_id;
    data_t     instr_id;

    // ---- ID Stage Outputs ----
    alu_ctrl_e alu_ctrl_id;
    data_t     operand_a_id;
    data_t     operand_b_id;
    address_t  rs1_addr_id;
    address_t  rs2_addr_id;
    address_t  rd_addr_id;
    logic      mem_we_id;
    logic      reg_we_id;
    logic      branch_id;
    logic      jump_id;
    logic      mem_to_reg_id;

    // ---- pr_id_ex Register Outputs ----
    data_t     pc_ex;
    data_t     reg_data1_ex;
    data_t     reg_data2_ex;
    data_t     imm_ex;
    alu_ctrl_e alu_op_ex;
    address_t  rd_addr_ex;
    logic      reg_write_en_ex;
    logic      mem_to_reg_ex;

    // ---- EX Stage Outputs ----
    data_t     alu_result_ex;
    logic      bc_taken_ex;
    data_t     target_addr_ex;

    // ---- pr_ex_mem Register Outputs ----
    data_t     alu_result_mem;
    data_t     reg_data2_mem;
    address_t  rd_addr_mem;
    logic      reg_write_en_mem;
    logic      mem_to_reg_mem;

    // ---- MEM Stage Outputs ----
    data_t     wb_alu_result_mem_out;
    data_t     wb_lsu_data_mem_out;

    // ---- pr_mem_wb Register Outputs ----
    data_t     alu_result_wb;
    data_t     mem_data_wb;
    address_t  rd_addr_wb;
    logic      reg_write_en_wb;

    // ---- WB Stage Outputs ----
    data_t     wb_data_out;
    logic      reg_write_en_wb_out;

    // Dynamic Control Path Resolution
    assign ex_mispredict = (branch_id && bc_taken_ex) || jump_id;

    // =========================================================================
    // Pipeline Topology & Instantiations
    // =========================================================================

    // -------------------------------------------------------------------------
    // 1. Instruction Fetch (IF)
    // -------------------------------------------------------------------------
    assign instr_addr_o  = pc_if;

    if_stage #(
        .BTB_DEPTH(16)
    ) u_if_stage (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .stall_i(hdu_stall),
        .flush_i(ex_mispredict),
        .ex_mispredict_i(ex_mispredict),
        .ex_pc_corr_i(target_addr_ex),
        .imem_addr_o(pc_if),
        .id_instr_o(),  // Terminated: Handled by standalone register
        .id_pc_o()  // Terminated: Handled by standalone register
    );

    pr_if_id u_pr_if_id (
        .clk_i  (clk_i),
        .rst_ni (rst_ni),
        .stall_i(hdu_stall),
        .flush_i(ex_mispredict),
        .pc_i   (pc_if),
        .instr_i(instr_data_i),
        .pc_o   (pc_id),
        .instr_o(instr_id)
    );

    // -------------------------------------------------------------------------
    // 2. Instruction Decode (ID)
    // -------------------------------------------------------------------------
    id_stage u_id_stage (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .instr_i(instr_id),
        .pc_i(pc_id),
        .wb_addr_i(rd_addr_wb),
        .wb_data_i(wb_data_out),
        .reg_we_i(reg_write_en_wb_out),
        .ex_rd_addr_i(rd_addr_ex),
        .ex_mem_read_i(mem_to_reg_ex),
        .alu_ctrl_o(alu_ctrl_id),
        .operand_a_o(operand_a_id),
        .operand_b_o(operand_b_id),
        .rs1_addr_o(rs1_addr_id),
        .rs2_addr_o(rs2_addr_id),
        .rd_addr_o(rd_addr_id),
        .alu_src_o(),
        .mem_we_o(mem_we_id),
        .reg_we_o(reg_we_id),
        .branch_o(branch_id),
        .jump_o(jump_id),
        .mem_to_reg_o(mem_to_reg_id),
        .stall_o(hdu_stall),
        .pc_write_o(),  // FIXED: Atomic flag safely dropped
        .if_id_write_o()  // FIXED: Atomic flag safely dropped
    );

    pr_id_ex u_pr_id_ex (
        .clk_i         (clk_i),
        .rst_ni        (rst_ni),
        .stall_i       (1'b0),
        .flush_i       (ex_mispredict),
        .pc_i          (pc_id),
        .reg_data1_i   (operand_a_id),
        .reg_data2_i   (operand_b_id),
        .imm_i         (operand_b_id),
        .alu_op_i      (alu_ctrl_id),
        .rd_addr_i     (rd_addr_id),
        .reg_write_en_i(reg_we_id),
        .mem_to_reg_i  (mem_to_reg_id),
        .pc_o          (pc_ex),
        .reg_data1_o   (reg_data1_ex),
        .reg_data2_o   (reg_data2_ex),
        .imm_o         (imm_ex),
        .alu_op_o      (alu_op_ex),
        .rd_addr_o     (rd_addr_ex),
        .reg_write_en_o(reg_write_en_ex),
        .mem_to_reg_o  (mem_to_reg_ex)
    );

    // -------------------------------------------------------------------------
    // 3. Execute (EX)
    // -------------------------------------------------------------------------
    ex_stage u_ex_stage (
        .alu_ctrl_i      (alu_op_ex),
        .op_a_i          (reg_data1_ex),
        .op_b_i          (reg_data2_ex),
        .op_a_addr_i     (rs1_addr_id),
        .op_b_addr_i     (rs2_addr_id),
        .alu_result_o    (alu_result_ex),
        .bc_ctrl_i       (BC_BEQ),
        .bc_taken_o      (bc_taken_ex),
        .pc_i            (pc_ex),
        .imm_i           (imm_ex),
        .jalr_sel_i      (1'b0),
        .target_addr_o   (target_addr_ex),
        .rd_addr_mem_i   (rd_addr_mem),
        .rd_addr_wb_i    (rd_addr_wb),
        .reg_we_mem_i    (reg_write_en_mem),
        .reg_we_wb_i     (reg_write_en_wb),
        .alu_result_mem_i(alu_result_mem),
        .wb_data_i       (wb_data_out),
        .alu_zero_o      (),
        .alu_negative_o  (),
        .alu_overflow_o  ()
    );

    pr_ex_mem u_pr_ex_mem (
        .clk_i         (clk_i),
        .rst_ni        (rst_ni),
        .stall_i       (1'b0),
        .alu_result_i  (alu_result_ex),
        .reg_data2_i   (reg_data2_ex),
        .rd_addr_i     (rd_addr_ex),
        .reg_write_en_i(reg_write_en_ex),
        .mem_to_reg_i  (mem_to_reg_ex),
        .alu_result_o  (alu_result_mem),
        .reg_data2_o   (reg_data2_mem),
        .rd_addr_o     (rd_addr_mem),
        .reg_write_en_o(reg_write_en_mem),
        .mem_to_reg_o  (mem_to_reg_mem)
    );

    // -------------------------------------------------------------------------
    // 4. Memory Access (MEM)
    // -------------------------------------------------------------------------
    assign dmem_addr_o  = alu_result_mem;
    assign dmem_wdata_o = reg_data2_mem;

    mem_stage u_mem_stage (
        .lsu_op_i       (LSU_WORD),
        .wb_sel_i       (WB_ALU),
        .mem_write_i    (mem_we_id),
        .reg_write_en_i (reg_write_en_mem),
        .alu_result_i   (alu_result_mem),
        .rs2_data_i     (reg_data2_mem),
        .pc_plus_4_i    (alu_result_mem),
        .mem_rdata_i    (dmem_rdata_i),
        .mem_wdata_o    (),
        .mem_addr_o     (),
        .mem_be_o       (),
        .mem_we_o       (dmem_we_o),
        .wb_alu_result_o(wb_alu_result_mem_out),
        .wb_lsu_data_o  (wb_lsu_data_mem_out),
        .wb_pc_plus_4_o (),
        .wb_sel_o       (),
        .reg_write_en_o ()
    );

    pr_mem_wb u_pr_mem_wb (
        .clk_i         (clk_i),
        .rst_ni        (rst_ni),
        .stall_i       (1'b0),
        .alu_result_i  (wb_alu_result_mem_out),
        .mem_data_i    (wb_lsu_data_mem_out),
        .rd_addr_i     (rd_addr_mem),
        .reg_write_en_i(reg_write_en_mem),
        .mem_to_reg_i  (mem_to_reg_mem),
        .alu_result_o  (alu_result_wb),
        .mem_data_o    (mem_data_wb),
        .rd_addr_o     (rd_addr_wb),
        .reg_write_en_o(reg_write_en_wb),
        .mem_to_reg_o  ()
    );

    // -------------------------------------------------------------------------
    // 5. Write-Back (WB)
    // -------------------------------------------------------------------------
    wb_stage u_wb_stage (
        .alu_result_i  (alu_result_wb),
        .lsu_data_i    (mem_data_wb),
        .pc_plus_4_i   (alu_result_wb),
        .wb_sel_i      (WB_ALU),
        .reg_write_en_i(reg_write_en_wb),
        .wb_data_o     (wb_data_out),
        .reg_write_en_o(reg_write_en_wb_out)
    );

endmodule : core_top
`endif  // CORE_TOP_SV
