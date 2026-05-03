// =============================================================================
// Project:         riscv-core
// File:            wbmux.sv
//
// Description:     Final stage multiplexer to select the data source for 
//                  Register File write-back.
//
// Dependencies:    riscv_types_pkg.sv
//
// License:         Apache-2.0
// =============================================================================
`ifndef WB_MUX_SV
`define WB_MUX_SV
`timescale 1ns / 1ps
`default_nettype none

module wb_mux
    import riscv_types_pkg::*;
(
    input  data_t   alu_result_i,
    input  data_t   lsu_data_i,
    input  data_t   pc_plus_4_i,
    input  wb_sel_e wb_sel_i,
    output data_t   wb_data_o
);

    always_comb begin
        wb_data_o = alu_result_i;
        unique case (wb_sel_i)
            WB_ALU: wb_data_o = alu_result_i;
            WB_MEM: wb_data_o = lsu_data_i;
            WB_PC4: wb_data_o = pc_plus_4_i;
        endcase
    end

endmodule : wb_mux
`endif
