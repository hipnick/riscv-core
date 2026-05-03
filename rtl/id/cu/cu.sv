// =============================================================================
// Project:         riscv-core
// File:            cu.sv
//
// Description:     The Control Unit decodes the RISC-V opcode, funct3, and funct7 fields to generate control 
//                  signals that dictate the behavior of the Execute (EX), Memory (MEM), and Write-Back (WB) stages.
//
// Dependencies:    riscv_types_pkg.sv
//
// License:         Apache-2.0
// =============================================================================

`default_nettype none

module cu
    import riscv_types_pkg::*;
(
    // Inputs
    input opcode_e opcode_i,
    input funct3_e funct3_i,
    input funct7_e funct7_i,

    // Outputs
    output alu_ctrl_e alu_ctrl_o,
    output logic      alu_src_o,     // 0: rs2_data, 1: immediate
    output logic      mem_to_reg_o,  // 0: ALU result, 1: Memory data
    output logic      reg_we_o,      // Register File Write Enable
    output logic      mem_we_o,      // Data Memory Write Enable
    output logic      branch_o,      // PC Branch Select
    output logic      jump_o         // PC Jump Select
);

    // --- Control Logic ---
    always_comb begin
        // Default State: Critical for preventing latches.
        alu_ctrl_o   = ALU_ADD;
        alu_src_o    = 1'b0;
        mem_to_reg_o = 1'b0;
        reg_we_o     = 1'b0;
        mem_we_o     = 1'b0;
        branch_o     = 1'b0;
        jump_o       = 1'b0;

        case (opcode_i)
            // R-Type: Register-Register operations
            OP_R_TYPE: begin
                reg_we_o = 1'b1;
                case (funct3_i)
                    F3_ADD_SUB:
                    alu_ctrl_o = (funct7_i == F7_VARIANT) ? ALU_SUB : ALU_ADD;
                    F3_SRL_SRA:
                    alu_ctrl_o = (funct7_i == F7_VARIANT) ? ALU_SRA : ALU_SRL;
                    F3_SLL: alu_ctrl_o = ALU_SLL;
                    F3_SLT: alu_ctrl_o = ALU_SLT;
                    F3_SLTU: alu_ctrl_o = ALU_SLTU;
                    F3_XOR: alu_ctrl_o = ALU_XOR;
                    F3_OR: alu_ctrl_o = ALU_OR;
                    F3_AND: alu_ctrl_o = ALU_AND;
                    default: alu_ctrl_o = ALU_ADD;
                endcase
            end

            // I-Type: Register-Immediate operations
            OP_I_TYPE: begin
                reg_we_o  = 1'b1;
                alu_src_o = 1'b1;
                case (funct3_i)
                    F3_ADD_SUB: alu_ctrl_o = ALU_ADD;
                    F3_SRL_SRA:
                    alu_ctrl_o = (funct7_i == F7_VARIANT) ? ALU_SRA : ALU_SRL;
                    F3_SLL: alu_ctrl_o = ALU_SLL;
                    F3_SLT: alu_ctrl_o = ALU_SLT;
                    F3_SLTU: alu_ctrl_o = ALU_SLTU;
                    F3_XOR: alu_ctrl_o = ALU_XOR;
                    F3_OR: alu_ctrl_o = ALU_OR;
                    F3_AND: alu_ctrl_o = ALU_AND;
                    default: alu_ctrl_o = ALU_ADD;
                endcase
            end

            // Load: Mem[rs1 + imm] -> rd
            OP_LOAD: begin
                reg_we_o     = 1'b1;
                alu_src_o    = 1'b1;
                mem_to_reg_o = 1'b1;
                alu_ctrl_o   = ALU_ADD;
            end

            // Store: rs2 -> Mem[rs1 + imm]
            OP_STORE: begin
                alu_src_o  = 1'b1;
                mem_we_o   = 1'b1;
                alu_ctrl_o = ALU_ADD;
            end

            // Branch: Comparison via ALU subtraction
            OP_BRANCH: begin
                branch_o = 1'b1;
                case (funct3_i)
                    F3_ADD_SUB: alu_ctrl_o = ALU_SUB;  // BEQ, BNE
                    F3_SLT, F3_SLTU:
                    alu_ctrl_o = ALU_SLT;  // BLT, BGE, BLTU, BGEU
                    F3_SLL, F3_XOR, F3_SRL_SRA, F3_OR, F3_AND:
                    alu_ctrl_o = ALU_SUB;  // Explicitly handle remaining enums
                    default: alu_ctrl_o = ALU_SUB;
                endcase
            end

            // Jump and Link
            OP_JAL, OP_JALR: begin
                reg_we_o   = 1'b1;
                jump_o     = 1'b1;
                alu_src_o  = (opcode_i == OP_JALR);
                alu_ctrl_o = ALU_ADD;
            end

            // Load Upper Immediate
            OP_LUI: begin
                reg_we_o   = 1'b1;
                alu_src_o  = 1'b1;
                alu_ctrl_o = ALU_COPY_B;
            end

            // Add Upper Immediate to PC
            OP_AUIPC: begin
                reg_we_o   = 1'b1;
                alu_src_o  = 1'b1;
                alu_ctrl_o = ALU_ADD;
            end

            // Illegal or Unimplemented Instructions
            default: begin
                // Maintain defaults defined at top
            end
        endcase
    end

endmodule : cu
