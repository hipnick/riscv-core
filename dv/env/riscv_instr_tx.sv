// =============================================================================
// Project:         riscv-core
// File:            riscv_instr_tx.sv
//
// Description:     UVM Sequence Item representing randomized fields of a 
//                  RISC-V instruction, complete with explicit ISA constraints.
//
// Dependencies:    riscv_types_pkg.sv
//
// License:         Apache-2.0
// =============================================================================
`ifndef RISCV_INSTR_TX_SV
`define RISCV_INSTR_TX_SV

class riscv_instr_tx extends uvm_sequence_item;

    // Randomized Instruction Fields
    rand opcode_e             opcode;
    rand address_t            rs1;
    rand address_t            rs2;
    rand address_t            rd;
    rand funct3_e             funct3;
    rand funct7_e             funct7;
    rand data_t imm;

    // Non-randomized Tracking Variables (Captured at runtime)
    data_t                    pc;
    data_t                    wb_data;

    `uvm_object_utils_begin(riscv_instr_tx)
        `uvm_field_enum(opcode_e, opcode, UVM_ALL_ON)
        `uvm_field_int(rs1,               UVM_ALL_ON)
        `uvm_field_int(rs2,               UVM_ALL_ON)
        `uvm_field_int(rd,                UVM_ALL_ON)
        `uvm_field_enum(funct3_e, funct3, UVM_ALL_ON)
        `uvm_field_enum(funct7_e, funct7, UVM_ALL_ON)
        `uvm_field_int(imm,               UVM_ALL_ON)
        `uvm_field_int(pc,                UVM_ALL_ON)
        `uvm_field_int(wb_data,           UVM_ALL_ON)
    `uvm_object_utils_end

    // Standard UVM Constructor
    function new(string name = "riscv_instr_tx");
        super.new(name);
    endfunction : new

    // Constraint 1: Restrict selections exclusively to valid supported opcodes
    constraint c_legal_opcodes {
        opcode inside {OP_R_TYPE, OP_I_TYPE, OP_LOAD, OP_STORE, OP_BRANCH, OP_LUI, OP_AUIPC};
    }

    // Constraint 2: 95% weight avoiding x0 destination to optimize hazard creation
    constraint c_avoid_x0_dest {
        rd == REG_ZERO dist { 1'b1 := 5, [1:31] := 95 };
    }

    // Constraint 3: Handle structural instruction sub-field dependencies
    constraint c_structural_fields {
        // Enforce valid functional variant matches for R-Type instructions
        if (opcode == OP_R_TYPE) {
            funct3 inside {F3_ADD_SUB, F3_SLL, F3_SLT, F3_SLTU, F3_XOR, F3_SRL_SRA, F3_OR, F3_AND};
            if (funct3 inside {F3_ADD_SUB, F3_SRL_SRA}) {
                funct7 inside {F7_BASE, F7_VARIANT};
            } else {
                funct7 == F7_BASE;
            }
        }
        
        // Enforce shift immediate bounds (0-31 shifts max)
        if (opcode == OP_I_TYPE && (funct3 == F3_SLL || funct3 == F3_SRL_SRA)) {
            imm[DATA_WIDTH-1:5] == '0;
            if (funct3 == F3_SRL_SRA) {
                funct7 inside {F7_BASE, F7_VARIANT};
            } else {
                funct7 == F7_BASE;
            }
        }

        // Align Load and Store immediate offsets to word boundaries (lower 2 bits = 0)
        if (opcode == OP_LOAD || opcode == OP_STORE) {
            imm[1:0] == 2'b00;
            imm[DATA_WIDTH-1:12] == '0; // Keep bounds within memory model size
        }
    }

    // Constraint 4: Intermittent branches targeting back and forward locations
    constraint c_intermittent_branches {
        if (opcode == OP_BRANCH) {
            imm[1:0] == 2'b00; // Branch offsets must be half-word/word aligned
            $signed(imm) inside {[-64:64]}; // Restricted boundary step size to prevent escaping memory boundaries
            imm != '0; // Avoid permanent infinite zero-offset loops
        }
    }

endclass : riscv_instr_tx

`endif // RISCV_INSTR_TX_SV