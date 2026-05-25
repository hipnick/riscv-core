// =============================================================================
// Project:         riscv-core
// File:            riscv_instr_tx.sv
//
// Description:     UVM Sequence Item representing a RISC-V instruction transaction
//
// Dependencies:    riscv_types_pkg.sv
//
// License:         Apache-2.0
// =============================================================================

`ifndef RISCV_INSTR_TX_SV
`define RISCV_INSTR_TX_SV

import riscv_types_pkg::*;

class riscv_instr_tx extends uvm_sequence_item;
    // --- Randomized Fields ---
    rand opcode_e  opcode;
    rand address_t rs1;
    rand address_t rs2;
    rand address_t rd;
    rand funct3_e  funct3;
    rand funct7_e  funct7;
    rand data_t    imm;
    rand imm_src_e imm_type;

    // --- UVM Automation Macros ---
    `uvm_object_utils_begin(riscv_instr_tx)
        `uvm_field_enum(opcode_e, opcode, UVM_DEFAULT)
        `uvm_field_int(rs1, UVM_DEFAULT)
        `uvm_field_int(rs2, UVM_DEFAULT)
        `uvm_field_int(rd, UVM_DEFAULT)
        `uvm_field_enum(funct3_e, funct3, UVM_DEFAULT)
        `uvm_field_enum(funct7_e, funct7, UVM_DEFAULT)
        `uvm_field_int(imm, UVM_DEFAULT)
        `uvm_field_enum(imm_src_e, imm_type, UVM_DEFAULT)
    `uvm_object_utils_end

    // --- Constraints ---
    // Constraints enforce valid RISC-V ISA behavior according to the opcode type
    constraint c_opcode_type_imm {
        (opcode == OP_R_TYPE) ->
        (imm_type == IMM_I);  // Dummy/unused for R-type
        (opcode == OP_I_TYPE || opcode == OP_LOAD || opcode == OP_JALR) ->
        (imm_type == IMM_I);
        (opcode == OP_STORE) -> (imm_type == IMM_S);
        (opcode == OP_BRANCH) -> (imm_type == IMM_B);
        (opcode == OP_LUI || opcode == OP_AUIPC) -> (imm_type == IMM_U);
        (opcode == OP_JAL) -> (imm_type == IMM_J);
    }

    constraint c_register_zero_weights {
        rs1 dist {
            REG_ZERO := 10,
            [1 : 31] := 90
        };
        rs2 dist {
            REG_ZERO := 10,
            [1 : 31] := 90
        };
        rd dist {
            REG_ZERO := 5,
            [1 : 31] := 95
        };
    }

    // --- Constructor ---
    function new(string name = "riscv_instr_tx");
        super.new(name);
    endfunction : new

endclass : riscv_instr_tx

`endif  // RISCV_INSTR_TX_SV
