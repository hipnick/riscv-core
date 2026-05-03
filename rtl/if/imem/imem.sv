// =============================================================================
// Project:         riscv-core
// File:            imem.sv
//
// Description:     Instruction Memory (IMEM) - Asynchronous Read ROM
//
// Dependencies:    riscv_types_pkg.sv
//
// License:         Apache-2.0
// =============================================================================

`ifndef IMEM_SV
`define IMEM_SV
`timescale 1ns / 1ps
`default_nettype none

module imem
    import riscv_types_pkg::*;
(
    input  data_t addr_i,
    output data_t instr_o
);

    // Instruction memory storage (Depth can be adjusted as needed)
    data_t mem[0:1023];

    initial begin
        $readmemh(IMEM_INIT_FILE, mem);
    end

    // Word-aligned addressing: RISC-V instructions are 32-bits (4 bytes)
    // We ignore the lower 2 bits of the byte address to index the word array
    assign instr_o = mem[addr_i[DATA_WIDTH_BITS+1:2]];

endmodule : imem
`endif
