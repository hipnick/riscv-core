// =============================================================================
// Project:         riscv-core
// File:            riscv_types_pkg.sv
//
// Description:     All the common parameters for the project
//
// Dependencies:    none
//
// License:         Apache-2.0
// =============================================================================
`ifndef RISCV_TYPES_PKG_SV
`define RISCV_TYPES_PKG_SV

package riscv_types_pkg;

    // -------------------------------------------------------------------------
    // Design Parameters
    // -------------------------------------------------------------------------
    localparam ALU_CTRL_WIDTH = 4;  // 4 bits allows for 16 unique operations
    localparam BC_CTRL_WIDTH = 3;
    localparam DATA_WIDTH = 32;  // Default RISC-V Word size
    localparam FWD_BITS = 2;
    // Pre-calculated log2 for shifters (5 bits needed to represent 0-31)
    localparam DATA_WIDTH_BITS = $clog2(DATA_WIDTH);
    localparam NUM_REGISTERS = 2 ** DATA_WIDTH_BITS;
    localparam OPCODE_BITS = 7;
    localparam string IMEM_INIT_FILE = "program.hex";

    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [DATA_WIDTH_BITS-1:0] address_t;
    localparam address_t REG_ZERO = {DATA_WIDTH_BITS{1'b0}};
    // Parameterized NOP (addi x0, x0, 0)
    localparam data_t INSTR_NOP = {{(DATA_WIDTH - 7) {1'b0}}, 7'h13};

    // -------------------------------------------------------------------------
    // ALU Operation Opcodes
    // These 4-bit codes are the "API" between the Decoder and the ALU.
    // -------------------------------------------------------------------------
    typedef enum logic [ALU_CTRL_WIDTH-1:0] {
        // Arithmetic
        ALU_ADD = 4'b0010,  // ADD
        ALU_SUB = 4'b0110,  // SUBSTRACT
        // Logical
        ALU_AND = 4'b0000,  // LOGIC AND
        ALU_OR = 4'b0001,  // LOGIC OR
        ALU_XOR = 4'b0100,  // LOGIC XOR
        // Shifts
        ALU_SLL = 4'b1000,  // Shift Left Logical
        ALU_SRL = 4'b1001,  // Shift Right Logical
        ALU_SRA = 4'b1010,  // Shift Right Arithmetic (Sign extension)
        // Comparisons
        ALU_SLT = 4'b1100,  // Set Less Than (Signed)
        ALU_SLTU = 4'b1101,  // Set Less Than (Unsigned)
        // Default/Pass-through (Optional)
        ALU_COPY_B = 4'b1111  // Simply outputs op_b_i (Useful for LUI)
    } alu_ctrl_e;

    localparam ALIGN_WIDTH = 1;
    // -------------------------------------------------------------------------
    // BC Operation Opcodes
    // -------------------------------------------------------------------------
    typedef enum logic [BC_CTRL_WIDTH-1:0] {
        BC_BEQ  = 3'b000,  // Branch Equal
        BC_BNE  = 3'b001,  // Branch Not Equal
        BC_BLT  = 3'b100,  // Branch Less Than
        BC_BGE  = 3'b101,  // Branch Greater Equal
        BC_BLTU = 3'b110,  // Branch Less Than Unsigned
        BC_BGEU = 3'b111   // Branch Greater Equal Unsigned
    } bc_ctrl_e;

    // -------------------------------------------------------------------------
    // Forwarding Selection Mux Encodings
    // -------------------------------------------------------------------------
    typedef enum logic [FWD_BITS-1:0] {
        FWD_ID_EX = 2'b00, // Default: Use Register File data
        FWD_WB    = 2'b01, // Forward from Write-back stage
        FWD_MEM   = 2'b10 // Forward from Memory stage
    } fwd_ctrl_e;

    typedef enum logic [OPCODE_BITS - 1:0] {
        OP_R_TYPE = 7'b0110011, // Register-Register: Arithmetic/Logic (e.g., add, sub, sll)
        OP_I_TYPE = 7'b0010011, // Register-Immediate: Arithmetic/Logic with constants (e.g., addi, slti)
        OP_LOAD   = 7'b0000011, // Load: Read data from Memory into a Register (e.g., lw, lh, lb)
        OP_STORE  = 7'b0100011, // Store: Write data from a Register into Memory (e.g., sw, sh, sb)
        OP_BRANCH = 7'b1100011, // Branch: Conditional PC offsets based on comparisons (e.g., beq, bne)
        OP_JAL    = 7'b1101111, // Jump and Link: Unconditional procedure call with PC-relative offset
        OP_JALR   = 7'b1100111, // Jump and Link Register: Indirect procedure call via register + offset
        OP_LUI    = 7'b0110111, // Load Upper Immediate: Build 32-bit constants (sets bits [31:12])
        OP_AUIPC  = 7'b0010111  // Add Upper Immediate to PC: PC-relative address calculation
    } opcode_e;

    // Funct3 definitions (Instruction bits [14:12])
    typedef enum logic [2:0] {
        F3_ADD_SUB = 3'b000,  // Shared by ADD/SUB and ADDI
        F3_SLL     = 3'b001,  // Shift Left Logical
        F3_SLT     = 3'b010,  // Set Less Than
        F3_SLTU    = 3'b011,  // Set Less Than Unsigned
        F3_XOR     = 3'b100,  // Exclusive OR
        F3_SRL_SRA = 3'b101,  // Shared by SRL and SRA
        F3_OR      = 3'b110,  // Logical OR
        F3_AND     = 3'b111   // Logical AND
    } funct3_e;

    // Funct7 definitions (Instruction bits [31:25])
    // In RV32I, only two patterns are standardly used
    typedef enum logic [6:0] {
        F7_BASE = 7'b0000000,  // Standard ALU operations
        F7_VARIANT  = 7'b0100000  // Variant operations (e.g., SUB instead of ADD)
    } funct7_e;

    // Immediate Source Enum (The "Schema" selector)
    typedef enum logic [2:0] {
        IMM_I,  // Arithmetic/Load
        IMM_S,  // Stores
        IMM_B,  // Branches
        IMM_U,  // Upper Immediates (LUI)
        IMM_J   // Jumps (JAL)
    } imm_src_e;

    typedef enum logic [2:0] {
        LSU_BYTE   = 3'b000,
        LSU_HALF   = 3'b001,
        LSU_WORD   = 3'b010,
        LSU_BYTE_U = 3'b100,  // Unsigned byte
        LSU_HALF_U = 3'b101   // Unsigned half
    } lsu_op_e;

    typedef enum logic [1:0] {
        WB_ALU = 2'b00,
        WB_MEM = 2'b01,
        WB_PC4 = 2'b10
    } wb_sel_e;

    // Architectural Field Widths (Per RISC-V Spec)
    localparam int IMM_I_WIDTH = 12;
    localparam int IMM_S_WIDTH = 12;
    localparam int IMM_B_WIDTH = 13;
    localparam int IMM_J_WIDTH = 21;

    // Derived Replication Counts (Total Width - Field Width)
    localparam int REP_I = DATA_WIDTH - IMM_I_WIDTH;
    localparam int REP_S = DATA_WIDTH - IMM_S_WIDTH;
    localparam int REP_B = DATA_WIDTH - IMM_B_WIDTH;
    localparam int REP_J = DATA_WIDTH - IMM_J_WIDTH;

    // Sign Bit Index
    localparam int SIGN_BIT = DATA_WIDTH - 1;

    parameter int BYTES_PER_WORD = DATA_WIDTH / 8;
    parameter int OFFSET_WIDTH = $clog2(BYTES_PER_WORD);

    typedef logic [BYTES_PER_WORD-1:0] bytes_enable_t;


endpackage

`endif  // RISCV_TYPES_PKG_SV
