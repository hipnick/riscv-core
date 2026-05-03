// =============================================================================
// Project:         riscv-core
// File:            imm_gen.sv
//
// Description:     Extracts and sign-extends immediate values from the RISC-V 
//                  instruction word based on the src_sel_i control signal.
//
// Dependencies:    riscv_types_pkg.sv
//
// License:         Apache-2.0
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module imm_gen
    import riscv_types_pkg::*;
(
    input  data_t inst_i,  // Use MSB from package
    output data_t imm_o    // Use MSB from package
);
    opcode_e opcode;
    assign opcode = opcode_e'(inst_i[6:0]);
    always_comb begin
        case (opcode)
            // I-Type: Arithmetic with immediates, Loads, JALR
            OP_I_TYPE, OP_LOAD, OP_JALR: begin
                imm_o = {{20{inst_i[31]}}, inst_i[31:20]};
            end

            // S-Type: Stores
            OP_STORE: begin
                imm_o = {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
            end

            // B-Type: Conditional Branches
            OP_BRANCH: begin
                imm_o = {
                    {19{inst_i[31]}},
                    inst_i[31],
                    inst_i[7],
                    inst_i[30:25],
                    inst_i[11:8],
                    1'b0
                };
            end

            // U-Type: LUI, AUIPC
            OP_LUI, OP_AUIPC: begin
                imm_o = {inst_i[31:12], 12'b0};
            end

            // J-Type: Jumps (JAL)
            OP_JAL: begin
                imm_o = {
                    {11{inst_i[31]}},
                    inst_i[31],
                    inst_i[19:12],
                    inst_i[20],
                    inst_i[30:21],
                    1'b0
                };
            end

            OP_R_TYPE: begin
                imm_o = '0;
            end

            // Default to I-Type for safety
            default: begin
                imm_o = {{20{inst_i[31]}}, inst_i[31:20]};
            end
        endcase
    end

endmodule : imm_gen
