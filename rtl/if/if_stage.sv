// =============================================================================
// Project:         riscv-core
// File:            if_stage.sv
//
// Description:     Instruction Fetch (IF) stage. Handles PC incrementing, 
//                  branch prediction (BTB) lookup, and next-PC selection.
//
// Dependencies:    riscv_types_pkg.sv, btb.sv
//
// License:         Apache-2.0
// =============================================================================
`ifndef IF_STAGE_SV
`define IF_STAGE_SV
`timescale 1ns / 1ps
`default_nettype none

module if_stage
    import riscv_types_pkg::*;
#(
    parameter int BTB_DEPTH = 16
) (
    input logic clk_i,
    input logic rst_ni,

    // Pipeline Control
    input logic stall_i,  // Freeze PC (e.g., hazard)
    input logic flush_i,  // Clear IF/ID register

    // Control Flow Corrections (from Execute Stage)
    input logic  ex_mispredict_i,  // Branch/Jump result was wrong
    input data_t ex_pc_corr_i,     // Correct target address

    // Instruction Memory (IMEM) Interface
    output data_t imem_addr_o,  // Address to fetch

    // Output to ID Stage
    output data_t id_instr_o,
    output data_t id_pc_o
);

    // -------------------------------------------------------------------------
    // Internal Signals
    // -------------------------------------------------------------------------
    data_t pc_current;
    data_t pc_next;
    data_t pc_plus4;
    data_t instr_fetched;
    logic  btb_hit;
    data_t btb_target;

    // -------------------------------------------------------------------------
    // Program Counter Instance
    // -------------------------------------------------------------------------
    pc u_pc (
        .clk_i    (clk_i),
        .rst_ni   (rst_ni),
        .pc_next_i(pc_next),
        .pc_o     (pc_current)
    );

    // -------------------------------------------------------------------------
    // Instruction Memory (Local or External Interface)
    // -------------------------------------------------------------------------
    // Note: imem_addr_o is driven to allow top-level memory connection
    assign imem_addr_o = pc_current;

    imem u_imem (
        .addr_i (pc_current),
        .instr_o(instr_fetched)
    );

    // -------------------------------------------------------------------------
    // Next PC Logic
    // -------------------------------------------------------------------------
    assign pc_plus4 = pc_current + 4;

    always_comb begin
        if (ex_mispredict_i) begin
            // Mispredicted branch/jump
            pc_next = ex_pc_corr_i;
        end else if (btb_hit) begin
            // BTB says this is a branch
            pc_next = btb_target;
        end else if (stall_i) begin
            // Stall (Hold current PC)
            pc_next = pc_current;
        end else begin
            // Sequential fetch
            pc_next = pc_plus4;
        end
    end

    // -------------------------------------------------------------------------
    // Branch Target Buffer (BTB) Instance
    // -------------------------------------------------------------------------
    btb #(
        .BTB_DEPTH(BTB_DEPTH)
    ) u_btb (
        .clk_i           (clk_i),
        .rst_ni          (rst_ni),
        .pc_if_i         (pc_current),
        .predict_target_o(btb_target),
        .hit_o           (btb_hit),
        // Update ports would be connected to EX stage results
        .update_i        (ex_mispredict_i),
        .actual_pc_i     (id_pc_o),
        .actual_target_i (ex_pc_corr_i)
    );

    // -------------------------------------------------------------------------
    // IF/ID Pipeline Register
    // -------------------------------------------------------------------------
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            id_instr_o <= INSTR_NOP;  // NOP (addi x0, x0, 0)
            id_pc_o    <= '0;
        end else if (flush_i) begin
            id_instr_o <= INSTR_NOP;  // Inject NOP
            id_pc_o    <= '0;
        end else if (!stall_i) begin
            id_instr_o <= instr_fetched;
            id_pc_o    <= pc_current;
        end
    end

endmodule : if_stage
`endif
