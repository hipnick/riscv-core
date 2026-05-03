// =============================================================================
// Project:         riscv-core
// File:            id_stage.sv
//
// Description:     Instruction Decode (ID) Stage.
//                  Integrates the Control Unit, Register File, Immediate 
//                  Generator, and Hazard Detection Unit.
//
// Dependencies:    riscv_types_pkg.sv, cu.sv, hdu.sv, imm_gen.sv, rf.sv
//
// License:         Apache-2.0
// =============================================================================
`ifndef ID_STAGE_SV
`define ID_STAGE_SV
`timescale 1ns / 1ps
`default_nettype none

module id_stage
    import riscv_types_pkg::*;
(
    input logic clk_i,
    input logic rst_ni,

    // Inputs from IF Stage
    input data_t instr_i,
    input data_t pc_i,

    // Inputs from WB Stage (Write Back)
    input address_t wb_addr_i,
    input data_t    wb_data_i,
    input logic     reg_we_i,

    // Inputs from EX/MEM stages for Hazard Detection
    input address_t ex_rd_addr_i,
    input logic     ex_mem_read_i,

    // Outputs to EX Stage
    output alu_ctrl_e alu_ctrl_o,
    output data_t     operand_a_o,
    output data_t     operand_b_o,
    output address_t  rs1_addr_o,
    output address_t  rs2_addr_o,
    output address_t  rd_addr_o,
    output logic      alu_src_o,
    output logic      mem_we_o,
    output logic      reg_we_o,
    output logic      branch_o,
    output logic      jump_o,
    output logic      mem_to_reg_o,

    // Pipeline Control (HDU)
    output logic stall_o,
    output logic pc_write_o,
    output logic if_id_write_o
);

    // -------------------------------------------------------------------------
    // Internal Signals
    // -------------------------------------------------------------------------
    data_t    rf_rs1_data;
    data_t    rf_rs2_data;
    data_t    imm_ext;

    // Instruction Field Extraction
    address_t rs1_addr;
    address_t rs2_addr;
    address_t rd_addr;
    opcode_e  opcode;

    assign rs1_addr   = instr_i[19:15];
    assign rs2_addr   = instr_i[24:20];
    assign rd_addr    = instr_i[11:7];
    assign opcode     = opcode_e'(instr_i[6:0]);

    // Output assignments for forwarding unit in EX stage
    assign rs1_addr_o = rs1_addr;
    assign rs2_addr_o = rs2_addr;
    assign rd_addr_o  = rd_addr;


    // -------------------------------------------------------------------------
    // Submodule: Control Unit (CU)
    // -------------------------------------------------------------------------
    cu u_cu (
        .opcode_i    (opcode),
        .funct3_i    (funct3_e'(instr_i[14:12])),
        .funct7_i    (funct7_e'(instr_i[31:25])),
        .alu_ctrl_o  (alu_ctrl_o),
        .alu_src_o   (alu_src_o),
        .reg_we_o    (reg_we_o),
        .mem_we_o    (mem_we_o),
        .mem_to_reg_o(mem_to_reg_o),
        .branch_o    (branch_o),
        .jump_o      (jump_o)
    );

    // -------------------------------------------------------------------------
    // Submodule: Register File (RF)
    // -------------------------------------------------------------------------
    rf u_rf (
        .clk_i     (clk_i),
        .rst_ni    (rst_ni),
        .rs1_addr_i(rs1_addr),
        .rs2_addr_i(rs2_addr),
        .rd_addr_i (wb_addr_i),
        .rd_data_i (wb_data_i),
        .rd_we_i   (reg_we_i),
        .rs1_data_o(rf_rs1_data),
        .rs2_data_o(rf_rs2_data)
    );

    // -------------------------------------------------------------------------
    // Submodule: Immediate Generator
    // -------------------------------------------------------------------------
    imm_gen u_imm_gen (
        .inst_i(instr_i),
        .imm_o (imm_ext)
    );

    // -------------------------------------------------------------------------
    // Submodule: Hazard Detection Unit (HDU)
    // -------------------------------------------------------------------------
    hdu u_hdu (
        .rs1_addr_id_i(rs1_addr),
        .rs2_addr_id_i(rs2_addr),
        .rd_addr_ex_i (ex_rd_addr_i),
        .mem_read_ex_i(ex_mem_read_i),
        .stall_o      (stall_o),
        .pc_write_o   (pc_write_o),
        .if_id_write_o(if_id_write_o)
    );

    // -------------------------------------------------------------------------
    // Operand Selection
    // -------------------------------------------------------------------------
    assign operand_a_o = (opcode == OP_AUIPC) ? pc_i : rf_rs1_data;
    assign operand_b_o = (alu_src_o) ? imm_ext : rf_rs2_data;

endmodule : id_stage
`endif
