// =============================================================================
// Project:         riscv-core
// File:            btb.sv
//
// Description:     Branch Target Buffer (BTB) for branch prediction.
//                  Stores previously taken branch targets to enable
//                  speculative instruction fetching.
//
// Dependencies:    riscv_types_pkg.sv
//
// License:         Apache-2.0
// =============================================================================

`ifndef BTB_SV
`define BTB_SV
`timescale 1ns / 1ps
`default_nettype none

module btb
    import riscv_types_pkg::*;
#(
    parameter int BTB_DEPTH = 16  // Number of branch entries to cache
) (
    input logic clk_i,
    input logic rst_ni,

    // Lookup Interface (Fetch Stage)
    input  data_t pc_if_i,
    output data_t predict_target_o,
    output logic  hit_o,

    // Update Interface (Execute Stage - Resolve)
    input logic  update_i,
    input data_t actual_pc_i,
    input data_t actual_target_i
);

    // Internal Storage Types
    typedef struct packed {
        logic  valid;
        data_t tag;     // PC of the branch
        data_t target;  // Predicted target
    } btb_entry_t;

    btb_entry_t mem[BTB_DEPTH];

    // -------------------------------------------------------------------------
    // Lookup Logic (Combinational)
    // -------------------------------------------------------------------------
    // Simple direct-mapped lookup using lower bits of PC as index
    localparam int IDX_WIDTH = $clog2(BTB_DEPTH);
    logic [IDX_WIDTH-1:0] read_idx;
    assign read_idx = pc_if_i[IDX_WIDTH+1:2];  // Word aligned index

    always_comb begin
        if (mem[read_idx].valid && (mem[read_idx].tag == pc_if_i)) begin
            hit_o            = 1'b1;
            predict_target_o = mem[read_idx].target;
        end else begin
            hit_o            = 1'b0;
            predict_target_o = '0;
        end
    end

    // -------------------------------------------------------------------------
    // Update Logic (Sequential)
    // -------------------------------------------------------------------------
    logic [IDX_WIDTH-1:0] write_idx;
    assign write_idx = actual_pc_i[IDX_WIDTH+1:2];

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            for (int i = 0; i < BTB_DEPTH; i++) begin
                mem[i].valid  <= 1'b0;
                mem[i].tag    <= '0;
                mem[i].target <= '0;
            end
        end else if (update_i) begin
            mem[write_idx].valid  <= 1'b1;
            mem[write_idx].tag    <= actual_pc_i;
            mem[write_idx].target <= actual_target_i;
        end
    end

endmodule : btb
`endif
