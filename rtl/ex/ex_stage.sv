// =============================================================================
// Project:         riscv-core
// File:            ex_stage.sv
//
// Description:     Structural wrapper for the Execute (EX) Stage.
//                  Instantiates ALU, Branch Comparator, and AGU using
//                  wildcard port connections (.*).
//
// Dependencies:    riscv_types_pkg.sv, alu.sv, bc.sv, agu.sv
//
// License:         Apache-2.0
// =============================================================================
`default_nettype none

module ex_stage
    import riscv_types_pkg::*;
(
    // ALU Interface
    input  alu_ctrl_e alu_ctrl_i,
    input  data_t     op_a_i,            // Renamed to match alu/bc ports
    input  data_t     op_b_i,            // Renamed to match alu/bc ports
    input  address_t  op_a_addr_i,
    input  address_t  op_b_addr_i,
    output data_t     alu_result_o,
    // Branch Comparator Interface
    input  bc_ctrl_e  bc_ctrl_i,
    output logic      bc_taken_o,
    // Address Generation Interface
    input  data_t     pc_i,
    input  data_t     imm_i,
    input  logic      jalr_sel_i,
    output data_t     target_addr_o,
    // Forwarding Inputs
    input  address_t  rd_addr_mem_i,
    input  address_t  rd_addr_wb_i,
    input  logic      reg_we_mem_i,
    input  logic      reg_we_wb_i,
    input  data_t     alu_result_mem_i,
    input  data_t     wb_data_i,
    // Status Flags
    output logic      alu_zero_o,
    output logic      alu_negative_o,
    output logic      alu_overflow_o
);
    fwd_ctrl_e fwd_a_o, fwd_b_o;
    data_t op_a_fwd, op_b_fwd;

    function automatic data_t compute_mux_fwd_ctrl(fwd_ctrl_e mux_fwd_ctrl,
                                                   data_t alu_result_mem,
                                                   data_t wb_data, data_t op);
        data_t data = op;

        unique case (mux_fwd_ctrl)
            FWD_MEM: data = alu_result_mem;
            FWD_WB: data = wb_data;
            FWD_ID_EX: data = op;
        endcase

        return data;
    endfunction

    // FWD Instance
    // -------------------------------------------------------------------------
    fwd u_fwd (
        .op_a_addr_i  (op_a_addr_i),
        .op_b_addr_i  (op_b_addr_i),
        .rd_addr_mem_i(rd_addr_mem_i),
        .reg_we_mem_i (reg_we_mem_i),
        .rd_addr_wb_i (rd_addr_wb_i),
        .reg_we_wb_i  (reg_we_wb_i),
        .fwd_a_o      (fwd_a_o),
        .fwd_b_o      (fwd_b_o)
    );

    // Operand A fwd mux
    assign op_a_fwd = compute_mux_fwd_ctrl(
        fwd_a_o, alu_result_mem_i, wb_data_i, op_a_i
    );

    // Operand B fwd mux
    assign op_b_fwd = compute_mux_fwd_ctrl(
        fwd_b_o, alu_result_mem_i, wb_data_i, op_b_i
    );

    // ALU Instance
    alu u_alu (
        .alu_ctrl_i    (alu_ctrl_i),
        .op_a_i        (op_a_fwd),
        .op_b_i        (op_b_fwd),
        .alu_result_o  (alu_result_o),
        .alu_zero_o    (alu_zero_o),
        .alu_negative_o(alu_negative_o),
        .alu_overflow_o(alu_overflow_o)
    );

    // Branch Comparator Instance
    bc u_bc (
        .op_a_i    (op_a_fwd),
        .op_b_i    (op_b_fwd),
        .bc_ctrl_i (bc_ctrl_i),
        .bc_taken_o(bc_taken_o)
    );

    // Target Address Calculation
    agu u_agu (
        .op_a_i       (op_a_fwd),
        .pc_i         (pc_i),
        .imm_i        (imm_i),
        .jalr_sel_i   (jalr_sel_i),
        .target_addr_o(target_addr_o)
    );

endmodule
