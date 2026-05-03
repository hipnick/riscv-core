// =============================================================================
// Project:         riscv-core
// File:            agu.sv
//
// Description:     Address Generation Unit (AGU) for RV32I.
//                  Calculates PC-relative and Absolute-Indirect targets.
//
// Dependencies:    riscv_types_pkg.sv
//
// License:         Apache-2.0
// =============================================================================

`default_nettype none

module agu
    import riscv_types_pkg::*;
(
    input  data_t pc_i,
    input  data_t imm_i,
    input  data_t op_a_i,        // rs1
    input  logic  jalr_sel_i,
    output data_t target_addr_o
);

    data_t target_base;
    data_t sum;

    // Selection logic for JALR vs JAL/Branch
    assign target_base = jalr_sel_i ? op_a_i : pc_i;

    assign sum = target_base + imm_i;
    // Address Calculation: Base + Offset
    // Forced Alignment: RISC-V requires the target address LSB to be 0
    assign target_addr_o = {sum[DATA_WIDTH-1:ALIGN_WIDTH], {ALIGN_WIDTH{1'b0}}};

endmodule
