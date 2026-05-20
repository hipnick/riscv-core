// =============================================================================
// Project:         riscv-core
// File:            core_tb.sv
//
// Description:     Hardware top-level testbench container. Instantiates the 
//                  DUT, manages clock/reset generation, and registers the 
//                  virtual interfaces into the UVM configuration database.
//
// Dependencies:    riscv_types_pkg.sv
//                  core_if.sv
//                  core_top.sv
//
// License:         Apache-2.0
// =============================================================================
`ifndef CORE_TB_SV
`define CORE_TB_SV
`timescale 1ns / 1ps
`default_nettype none

module core_tb;

    import uvm_pkg::*;
    import riscv_types_pkg::*;
    `include "uvm_macros.svh"

    // -------------------------------------------------------------------------
    // System Clock & Reset Generation
    // -------------------------------------------------------------------------
    logic clk;
    logic rst_n;

    // 50MHz Clock Generation (20ns period)
    initial begin
        clk = 1'b0;
        forever #10ns clk = ~clk;
    end

    // Active-Low Reset Generation
    initial begin
        rst_n = 1'b0;
        #40ns;
        rst_n = 1'b1;
    end

    // -------------------------------------------------------------------------
    // Physical Interface Instantiation
    // -------------------------------------------------------------------------
    core_if intf (
        .clk  (clk),
        .rst_n(rst_n)
    );

    // -------------------------------------------------------------------------
    // Device Under Test (DUT) Instantiation
    // -------------------------------------------------------------------------
    core_top u_dut (
        .clk_i (clk),
        .rst_ni(rst_n),

        // Instruction Memory Bus
        .instr_addr_o(intf.imem_addr),
        .instr_data_i(intf.imem_rdata),

        // Data Memory Bus
        .dmem_addr_o (intf.dmem_addr),
        .dmem_wdata_o(intf.dmem_wdata),
        .dmem_rdata_i(intf.dmem_rdata),
        .dmem_we_o   (intf.dmem_we)
    );

    // -------------------------------------------------------------------------
    // Bind Statement for Passive Verification Points
    // -------------------------------------------------------------------------
    // Connects internal pipeline writeback signals directly to interface logic
    // for passive scoreboard monitoring without hacking the DUT port list.
    assign intf.wb_reg_addr = u_dut.u_wb_stage.rd_addr_o;
    assign intf.wb_reg_data = u_dut.u_wb_stage.rd_data_o;
    assign intf.wb_reg_we   = u_dut.u_wb_stage.reg_write_en_o;

    // -------------------------------------------------------------------------
    // UVM Configuration Database & Test Execution Entry
    // -------------------------------------------------------------------------
    initial begin
        // Inject the physical interface wrapper into the global UVM config space 
        // as a "virtual interface" pointer accessible by downstream drivers/monitors.
        uvm_config_db#(virtual core_if)::set(uvm_root::get(), "*", "vif", intf);

        // Start the UVM phase machine (overridden via command-line +UVM_TESTNAME)
        run_test();
    end

    // -------------------------------------------------------------------------
    // Simulation Waveform Dumping (Standard EDA Tools)
    // -------------------------------------------------------------------------
    initial begin
        if ($test$plusargs("DUMP_WAVES")) begin
            $dumpfile("sim_vcd.vcd");
            $dumpvars(0, core_tb);
        end
    end

endmodule : core_tb

`endif  // CORE_TB_SV
