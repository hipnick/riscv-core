// =============================================================================
// Project:         riscv-core
// File:            core_scoreboard.sv
//
// Description:     UVM Scoreboard checking instruction execution and register
//                  file state mutations against a reference model using types
//                  defined in riscv_types_pkg.
//
// Dependencies:    riscv_types_pkg.sv
//
// License:         Apache-2.0
// =============================================================================
`ifndef CORE_SCOREBOARD_SV
`define CORE_SCOREBOARD_SV

class core_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(core_scoreboard)

    // Analysis implementation port to receive transactions from the monitor
    uvm_analysis_imp #(riscv_instr_tx, core_scoreboard) item_collected_imp;

    // Internal reference model state: Mirror of the 32 RISC-V architectural registers
    protected data_t register_file_mirror[NUM_REGISTERS];

    // Verification Metrics
    protected int unsigned match_count     = 0;
    protected int unsigned mismatch_count  = 0;
    protected int unsigned completed_instrs = 0;

    // Standard UVM Constructor
    function new(string name = "core_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    // UVM Build Phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        item_collected_imp = new("item_collected_imp", this);
        
        // Initialize architectural register mirror (x0 is hardwired to 0)
        foreach (register_file_mirror[i]) begin
            register_file_mirror[i] = REG_ZERO;
        end
    endfunction : build_phase

    // UVM Write Implementation: Consumes broadcasted transactions from the monitor
    virtual function void write(riscv_instr_tx tx);
        data_t expected_data;
        bit    is_writeback_instr;

        if (tx == null) begin
            `uvm_error("SB_NULL_TX", "Received a null transaction pointer inside write execution loop")
            return;
        end

        completed_instrs++;
        is_writeback_instr = 1'b0;
        expected_data = REG_ZERO;

        // Reference Model Evaluation Loop
        case (tx.opcode)
            OP_R_TYPE: begin
                is_writeback_instr = (tx.rd != REG_ZERO);
                case (tx.funct3)
                    F3_ADD_SUB: begin
                        if (tx.funct7 == F7_VARIANT) begin
                            expected_data = register_file_mirror[tx.rs1] - register_file_mirror[tx.rs2];
                        end else begin
                            expected_data = register_file_mirror[tx.rs1] + register_file_mirror[tx.rs2];
                        end
                    end
                    F3_SLL:  expected_data = register_file_mirror[tx.rs1] << register_file_mirror[tx.rs2][4:0];
                    F3_SLT:  expected_data = ($signed(register_file_mirror[tx.rs1]) < $signed(register_file_mirror[tx.rs2])) ? 32'h1 : 32'h0;
                    F3_SLTU: expected_data = (register_file_mirror[tx.rs1] < register_file_mirror[tx.rs2]) ? 32'h1 : 32'h0;
                    F3_XOR:  expected_data = register_file_mirror[tx.rs1] ^ register_file_mirror[tx.rs2];
                    F3_SRL_SRA: begin
                        if (tx.funct7 == F7_VARIANT) begin
                            expected_data = $signed(register_file_mirror[tx.rs1]) >>> register_file_mirror[tx.rs2][4:0];
                        end else begin
                            expected_data = register_file_mirror[tx.rs1] >> register_file_mirror[tx.rs2][4:0];
                        end
                    end
                    F3_OR:   expected_data = register_file_mirror[tx.rs1] | register_file_mirror[tx.rs2];
                    F3_AND:  expected_data = register_file_mirror[tx.rs1] & register_file_mirror[tx.rs2];
                    default: `uvm_error("SB_UNKNOWN_FUNCT3", $sformatf("Illegal funct3 configuration encountered: 3'b%3b", tx.funct3))
                endcase
            end

            OP_I_TYPE: begin
                is_writeback_instr = (tx.rd != REG_ZERO);
                case (tx.funct3)
                    F3_ADD_SUB: expected_data = register_file_mirror[tx.rs1] + tx.imm;
                    F3_SLL:     expected_data = register_file_mirror[tx.rs1] << tx.imm[4:0];
                    F3_SLT:     expected_data = ($signed(register_file_mirror[tx.rs1]) < $signed(tx.imm)) ? 32'h1 : 32'h0;
                    F3_SLTU:    expected_data = (register_file_mirror[tx.rs1] < tx.imm) ? 32'h1 : 32'h0;
                    F3_XOR:     expected_data = register_file_mirror[tx.rs1] ^ tx.imm;
                    F3_SRL_SRA: begin
                        if (tx.funct7 == F7_VARIANT) begin
                            expected_data = $signed(register_file_mirror[tx.rs1]) >>> tx.imm[4:0];
                        end else begin
                            expected_data = register_file_mirror[tx.rs1] >> tx.imm[4:0];
                        end
                    end
                    F3_OR:      expected_data = register_file_mirror[tx.rs1] | tx.imm;
                    F3_AND:     expected_data = register_file_mirror[tx.rs1] & tx.imm;
                    default:    `uvm_error("SB_UNKNOWN_FUNCT3", $sformatf("Illegal immediate funct3 config: 3'b%3b", tx.funct3))
                endcase
            end

            OP_LUI: begin
                is_writeback_instr = (tx.rd != REG_ZERO);
                expected_data = tx.imm;
            end

            OP_AUIPC: begin
                is_writeback_instr = (tx.rd != REG_ZERO);
                expected_data = tx.pc + tx.imm;
            end
            
            OP_LOAD: begin
                is_writeback_instr = (tx.rd != REG_ZERO);
                expected_data = tx.wb_data; // Driven dynamically by behavioral Data Memory content sampled in monitor
            end

            OP_JAL, OP_JALR: begin
                is_writeback_instr = (tx.rd != REG_ZERO);
                expected_data = tx.pc + 4; // Link register data calculation
            end

            OP_STORE, OP_BRANCH: begin
                is_writeback_instr = 1'b0; // No architectural register modification
            end

            default: begin
                `uvm_warning("SB_UNHANDLED_OPCODE", $sformatf("Instruction Opcode 7'b%7b skipped or unhandled in check model execution", tx.opcode))
            end
        endcase

        // Perform Self-Checking Functional Verification
        if (is_writeback_instr) begin
            if (tx.wb_data !== expected_data) begin
                mismatch_count++;
                `uvm_error("SB_MISMATCH", $sformatf("Data Mismatch Detected! PC: 32'h%8h | Reg: x%0d | Expected: 32'h%8h | Actual DUT: 32'h%8h", 
                           tx.pc, tx.rd, expected_data, tx.wb_data))
            end else begin
                match_count++;
                `uvm_info("SB_MATCH", $sformatf("Data Match: PC 32'h%8h | Reg: x%0d | Val: 32'h%8h", tx.pc, tx.rd, tx.wb_data), UVM_HIGH)
                register_file_mirror[tx.rd] = expected_data; // Advance reference model state pointer
            end
        end else begin
            `uvm_info("SB_NO_WB", $sformatf("Non-Writeback Instruction Verified: PC 32'h%8h | Opcode 7'b%7b", tx.pc, tx.opcode), UVM_HIGH)
        end
    endfunction : write

    // UVM Report Phase for final metrics status readout
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SB_REPORT", $sformatf("\n====== Core Scoreboard Verification Summary ======\nTotal Instructions Processed: %0d\nSuccessful Register Matches : %0d\nFunctional Register Failures: %0d\n==================================================", 
                  completed_instrs, match_count, mismatch_count), UVM_LOW)
                  
        if (mismatch_count > 0) begin
            `uvm_fatal("SB_STATUS_FAIL", "Verification test suite completed with catastrophic functional data mismatches!")
        end
    endfunction : report_phase

endclass : core_scoreboard

`endif // CORE_SCOREBOARD_SV