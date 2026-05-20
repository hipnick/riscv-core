// =============================================================================
// Project:         riscv-core
// File:            core_if.sv
//
// Description:     SystemVerilog interface bundling the Instruction and Data 
//                  Memory buses, along with system control signals.
//
// Dependencies:    riscv_types_pkg.sv
//
// License:         Apache-2.0
// =============================================================================
`ifndef CORE_IF_SV
`define CORE_IF_SV
`timescale 1ns / 1ps
`default_nettype none

interface core_if
    import riscv_types_pkg::*;
(
    input logic clk,
    input logic rst_n
);

    // -------------------------------------------------------------------------
    // Instruction Memory Interface (Bus / Agent Pins)
    // -------------------------------------------------------------------------
    data_t    imem_addr;
    data_t    imem_rdata;
    logic     imem_valid;

    // -------------------------------------------------------------------------
    // Data Memory Interface (Bus / Agent Pins)
    // -------------------------------------------------------------------------
    data_t    dmem_addr;
    data_t    dmem_wdata;
    data_t    dmem_rdata;
    logic     dmem_we;
    logic     dmem_valid;

    // -------------------------------------------------------------------------
    // Verification Monitor / Passive Sampling Points
    // -------------------------------------------------------------------------
    address_t wb_reg_addr;
    data_t    wb_reg_data;
    logic     wb_reg_we;

    // -------------------------------------------------------------------------
    // Clocking Blocks for Synchronous Driving and Sampling
    // -------------------------------------------------------------------------

    // Driver Clocking Block (Active Role)
    clocking drv_cb @(posedge clk);
        default input #1ns output #1ns;
        output imem_rdata, imem_valid;
        output dmem_rdata, dmem_valid;
        input imem_addr;
        input dmem_addr, dmem_wdata, dmem_we;
    endclocking : drv_cb

    // Monitor Clocking Block (Passive Role)
    clocking mon_cb @(posedge clk);
        default input #1ns output #1ns;
        input imem_addr, imem_rdata, imem_valid;
        input dmem_addr, dmem_wdata, dmem_rdata, dmem_we, dmem_valid;
        input wb_reg_addr, wb_reg_data, wb_reg_we;
    endclocking : mon_cb

    // -------------------------------------------------------------------------
    // Modports
    // -------------------------------------------------------------------------
    modport driver(clocking drv_cb, input rst_n);
    modport monitor(clocking mon_cb, input rst_n);

endinterface : core_if

`endif  // CORE_IF_SV
