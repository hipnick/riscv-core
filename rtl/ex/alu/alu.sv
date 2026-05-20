// =============================================================================
// Project:         riscv-core
// File:            alu.sv
//
// Description:     32-bit Arithmetic Logic Unit (ALU) for RV32I ISA.
//                  Handles arithmetic, logical, and shift operations.
//
// Dependencies:    riscv_types_pkg.sv
//
// License:         Apache-2.0
// =============================================================================
`ifndef ALU_SV
`define ALU_SV
`timescale 1ns / 1ps
`default_nettype none

module alu
    import riscv_types_pkg::*;
(
    // Functional Inputs
    input  alu_ctrl_e alu_ctrl_i,
    input  data_t     op_a_i,
    input  data_t     op_b_i,
    // Functional Outputs
    output data_t     alu_result_o,
    // Status Flags
    output logic      alu_zero_o,
    output logic      alu_negative_o,
    output logic      alu_overflow_o
);

    // Internal result signal
    data_t result;

    // Flag: Overflow (Specific to signed ADD/SUB)
    // Logic: If operands have the same sign but the result has a different sign
    // Internal helper signals for readability
    logic  add_overflow;
    logic  sub_overflow;

    // ADD Overflow: op_a_i and op_b_i have same sign, but result has different sign
    assign add_overflow = (op_a_i[DATA_WIDTH-1] == op_b_i[DATA_WIDTH-1]) && (result[DATA_WIDTH-1] != op_a_i[DATA_WIDTH-1]);

    // SUB Overflow: op_a_i and op_b_i have different signs, and result sign differs from op_a_i
    assign sub_overflow = (op_a_i[DATA_WIDTH-1] != op_b_i[DATA_WIDTH-1]) && (result[DATA_WIDTH-1] != op_a_i[DATA_WIDTH-1]);

    // -------------------------------------------------------------------------
    // Combinational Logic Block
    // -------------------------------------------------------------------------
    always_comb begin
        // DEFAULT-AT-TOP: Initialize all outputs to a safe state
        result         = '0;
        alu_overflow_o = 1'b0;

        unique case (alu_ctrl_i)
            // Arithmetic
            ALU_ADD: begin
                result         = op_a_i + op_b_i;
                alu_overflow_o = add_overflow;
            end
            ALU_SUB: begin
                result         = op_a_i - op_b_i;
                alu_overflow_o = sub_overflow;
            end

            // Logical
            ALU_AND: result = op_a_i & op_b_i;  // Bitwise AND
            ALU_OR:  result = op_a_i | op_b_i;  // Bitwise OR
            ALU_XOR: result = op_a_i ^ op_b_i;  // Bitwise XOR

            // Shifts (Note: RISC-V shifts only use the bottom 5 bits for 32-bit)
            ALU_SLL:
            result = op_a_i << op_b_i[DATA_WIDTH_BITS-1:0];  //Shift Left Logical
            ALU_SRL:
            result = op_a_i >> op_b_i[DATA_WIDTH_BITS-1:0];  //Shift Right Logical
            ALU_SRA:
            result = data_t'($signed(op_a_i) >>> op_b_i[DATA_WIDTH_BITS-1:0])
                ;  //Shift Right Arithmetic (Sign-preserved)

            // Comparisons (SHIFT LESS THAN (Signed)/(Unsigned))
            ALU_SLT:  result = ($signed(op_a_i) < $signed(op_b_i)) ? '1 : '0;
            ALU_SLTU: result = (op_a_i < op_b_i) ? '1 : '0;

            // Pass-through for LUI (Load Upper Immediate)/Other operations
            ALU_COPY_B: result = op_b_i;
        endcase
    end

    // -------------------------------------------------------------------------
    // Output Assignments
    // -------------------------------------------------------------------------
    assign alu_result_o   = result;

    // Flag: Zero is true if all bits in result are 0
    assign alu_zero_o     = (result == '0);

    // Flag: Negative is simply the Most Significant Bit (Sign bit)
    assign alu_negative_o = result[DATA_WIDTH-1];

endmodule : alu
`endif
