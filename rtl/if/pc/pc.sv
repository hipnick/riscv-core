// =============================================================================
// Project:         riscv-core
// File:            pc.sv
//
// Description:     32-bit Program Counter register.
//                  Holds the memory address of the current instruction.
//
// Dependencies:    riscv_types_pkg.sv
//
// License:         Apache-2.0
// =============================================================================
`ifndef PC_SV
`define PC_SV
`timescale 1ns / 1ps
`default_nettype none

module pc
    import riscv_types_pkg::*;
(
    input  logic  clk_i,      // System clock
    input  logic  rst_ni,     // Active-low asynchronous reset
    input  data_t pc_next_i,  // Next address (PC+4 or Branch target)
    output data_t pc_o        // Current instruction address
);

    // -------------------------------------------------------------------------
    // Sequential Logic: PC Register
    // -------------------------------------------------------------------------
    always_ff @(posedge clk_i or negedge rst_ni) begin : rg_pc_update
        if (!rst_ni) begin
            pc_o <= '0;
        end else begin
            pc_o <= pc_next_i;
        end
    end

endmodule : pc
`endif
