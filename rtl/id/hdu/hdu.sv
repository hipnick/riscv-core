// =============================================================================
// Project:         riscv-core
// File:            hdu.sv
//
// Description:     Hazard Detection Unit (HDU)
//                  Identifies "Load-Use" data hazards and stalls the pipeline 
//                  to allow memory data to become available.
//
// Dependencies:    riscv_types_pkg.sv
//
// License:         Apache-2.0
// =============================================================================
`ifndef HDU_SV
`define HDU_SV
`timescale 1ns / 1ps
`default_nettype none

module hdu
    import riscv_types_pkg::*;
(
    // Inputs from ID stage
    input address_t rs1_addr_id_i,  // Source register 1 address in ID stage
    input address_t rs2_addr_id_i,  // Source register 2 address in ID stage

    // Inputs from EX stage
    input address_t rd_addr_ex_i,  // Destination register address in EX stage
    input logic     mem_read_ex_i, // High if instruction in EX is a Load

    // Outputs to Pipeline Control
    output logic pc_write_o,  // Enable signal for PC (0 to stall)
    output logic if_id_write_o,   // Enable signal for IF/ID register (0 to stall)
    output logic stall_o  // Signal to force a NOP into EX stage
);

    // -------------------------------------------------------------------------
    // Hazard Detection Logic
    // -------------------------------------------------------------------------
    // A stall is required if:
    // 1. The instruction in EX is a Load (mem_read_ex_i == 1)
    // 2. The EX destination register matches either ID source register
    // 3. The destination is not x0 (RISC-V x0 is hardwired to 0 and cannot cause hazards)
    // -------------------------------------------------------------------------
    always_comb begin
        // Default State: No stall
        pc_write_o    = 1'b1;
        if_id_write_o = 1'b1;
        stall_o       = 1'b0;

        if (mem_read_ex_i && (rd_addr_ex_i != REG_ZERO)) begin
            if ((rd_addr_ex_i == rs1_addr_id_i) || (rd_addr_ex_i == rs2_addr_id_i)) begin
                pc_write_o    = 1'b0;
                if_id_write_o = 1'b0;
                stall_o       = 1'b1;
            end
        end
    end

endmodule : hdu

`endif
