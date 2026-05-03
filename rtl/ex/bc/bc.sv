// =============================================================================
// Project:         riscv-core
// File:            bc.sv
//
// Description:     32-bit Branch Comparator (BC) for RV32I ISA.
//                  Handles conditional branch logic comparisons.
//
// Dependencies:    riscv_types_pkg.sv
//
// License:         Apache-2.0
// =============================================================================
`default_nettype none

module bc
    import riscv_types_pkg::*;
(
    input  bc_ctrl_e bc_ctrl_i,
    input  data_t    op_a_i,
    input  data_t    op_b_i,
    output logic     bc_taken_o
);

    always_comb begin
        // Default assignment to avoid latches
        bc_taken_o = 1'b0;

        unique case (bc_ctrl_i)
            BC_BEQ:  bc_taken_o = (op_a_i == op_b_i);  // Branch Equal
            BC_BNE:  bc_taken_o = (op_a_i != op_b_i);  // Branch Not Equal
            BC_BLT:  bc_taken_o = ($signed(op_a_i) < $signed(op_b_i));  // Branch Less Than
            BC_BGE:  bc_taken_o = ($signed(op_a_i) >= $signed(op_b_i));  // Branch Greater Equal
            BC_BLTU: bc_taken_o = (op_a_i < op_b_i);  // Branch Less Than Unsigned
            BC_BGEU: bc_taken_o = (op_a_i >= op_b_i);  // Branch Greater Equal Unsigned
        endcase
    end

endmodule
