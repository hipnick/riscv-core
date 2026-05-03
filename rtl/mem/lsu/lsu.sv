// =============================================================================
// Project:         riscv-core
// File:            lsu.sv
//
// Description:     Parameterized Load-Store Unit. 
//                  Scales alignment and sign-extension for RV32/RV64.
//
// Dependencies:    riscv_types_pkg.sv
//
// License:         Apache-2.0
// =============================================================================
`ifndef LSU_SV
`define LSU_SV
`timescale 1ns / 1ps
`default_nettype none

module lsu
    import riscv_types_pkg::*;
(
    input  lsu_op_e       lsu_op_i,
    input  data_t         addr_i,
    input  data_t         wdata_i,
    input  data_t         mem_rdata_i,
    input  logic          mem_write_i,
    output data_t         mem_wdata_o,
    output bytes_enable_t mem_be_o,
    output data_t         lsu_rdata_o
);

    logic [OFFSET_WIDTH-1:0] byte_offset;
    logic [OFFSET_WIDTH-1:0] byte_val;
    assign byte_offset = addr_i[OFFSET_WIDTH-1:0];

    assign byte_val    = OFFSET_WIDTH'(8);

    // -------------------------------------------------------------------------
    // STORE Logic: Alignment and Masking
    // -------------------------------------------------------------------------
    always_comb begin
        mem_be_o    = '0;
        mem_wdata_o = '0;

        if (mem_write_i) begin
            unique case (lsu_op_i)
                LSU_BYTE, LSU_BYTE_U: begin
                    mem_be_o    = BYTES_PER_WORD'(1'b1) << byte_offset;
                    mem_wdata_o = wdata_i << (byte_val * byte_offset);
                end
                LSU_HALF, LSU_HALF_U: begin
                    // Aligned to 2-byte boundary
                    mem_be_o = BYTES_PER_WORD'(2'b11) << (byte_offset & ~1'b1);
                    mem_wdata_o = wdata_i << (byte_val * (byte_offset & ~1'b1));
                end
                LSU_WORD: begin
                    // Aligned to 4-byte boundary
                    mem_be_o = 4'hf << (byte_offset & ~2'b11);
                    mem_wdata_o = wdata_i << (byte_val * (byte_offset & ~2'b11));
                end
            endcase
        end
    end

    // -------------------------------------------------------------------------
    // LOAD Logic: Shifting and Sign-Extension
    // -------------------------------------------------------------------------
    data_t shifted_rdata;
    assign shifted_rdata = mem_rdata_i >> (byte_val * byte_offset);

    always_comb begin
        lsu_rdata_o = shifted_rdata;

        unique case (lsu_op_i)
            LSU_BYTE:
            lsu_rdata_o = {
                {(DATA_WIDTH - 8) {shifted_rdata[7]}}, shifted_rdata[7:0]
            };
            LSU_BYTE_U:
            lsu_rdata_o = {{(DATA_WIDTH - 8) {1'b0}}, shifted_rdata[7:0]};

            LSU_HALF:
            lsu_rdata_o = {
                {(DATA_WIDTH - 16) {shifted_rdata[15]}}, shifted_rdata[15:0]
            };
            LSU_HALF_U:
            lsu_rdata_o = {{(DATA_WIDTH - 16) {1'b0}}, shifted_rdata[15:0]};

            // In RV64, LW (Load Word) must be sign-extended to 64 bits.
            // In RV32, this is essentially a pass-through.
            LSU_WORD:
            lsu_rdata_o = {
                {(DATA_WIDTH - 32) {shifted_rdata[31]}}, shifted_rdata[31:0]
            };
        endcase
    end

endmodule : lsu
`endif
