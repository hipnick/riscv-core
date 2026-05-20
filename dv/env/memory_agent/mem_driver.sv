// =============================================================================
// Project:         riscv-core
// File:            mem_driver.sv
//
// Description:     UVM driver for the instruction and data memory interfaces.
//                  Translates riscv_instr_tx transactions into cycle-accurate
//                  pin-level memory operations.
//
// Dependencies:    riscv_types_pkg.sv, riscv_instr_tx.sv
//
// License:         Apache-2.0
// =============================================================================
`ifndef MEM_DRIVER_SV
`define MEM_DRIVER_SV

import riscv_types_pkg::*;

class mem_driver extends uvm_driver #(riscv_instr_tx);
    `uvm_component_utils(mem_driver)

    // Virtual interface handle to drive the pins
    virtual core_if  vif;

    // Behavioral memory array for backdoor loading (32-bit address space mapping)
    protected data_t ram_model[data_t];

    // -------------------------------------------------------------------------
    // Constructor
    // -------------------------------------------------------------------------
    function new(string name = "mem_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    // -------------------------------------------------------------------------
    // Build Phase
    // -------------------------------------------------------------------------
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual core_interface)::get(
                this, "", "vif", vif
            )) begin
            `uvm_fatal(
                "DRV_NO_VIF",
                "Virtual interface handle 'vif' not found in uvm_config_db")
        end
    endfunction : build_phase

    // -------------------------------------------------------------------------
    // Run Phase
    // -------------------------------------------------------------------------
    virtual task run_phase(uvm_phase phase);
        // Initialize interface to idle states
        reset_signals();

        // Wait for reset release before starting sequence driving
        wait (vif.rst_ni === 1'b1);

        forever begin
            // Pull the next sequence item (transaction packet) from the sequencer
            seq_item_port.get_next_item(req);

            // Execute the cycle-accurate pin drive orchestration
            drive_transaction(req);

            // Handshake back to the sequencer
            seq_item_port.item_done();
        end
    endtask : run_phase

    // -------------------------------------------------------------------------
    // Low-Level Protocol Driving Tasks
    // -------------------------------------------------------------------------

    // Reset driving lines to benign states
    protected task reset_signals();
        // Assuming standard memory bus signaling names here
        vif.imem_rdata <= '0;
        vif.dmem_rdata <= '0;
        vif.imem_ready <= 1'b0;
        vif.dmem_ready <= 1'b0;
    endtask : reset_signals

    // Cycle-accurate protocol driver implementation
    protected task drive_transaction(riscv_instr_tx tx);
        // Wait for the clock edge to align with cycle-accurate timing
        @(posedge vif.clk_i);

        // Phase 1 specific behavior: Check if instruction fetch is requested by core
        if (vif.imem_req === 1'b1) begin
            // Sample the requested PC from the core
            bit [31:0] fetch_addr = vif.imem_addr;

            // Check if the requested address exists in our backdoor-loaded model
            if (ram_model.exists(fetch_addr)) begin
                vif.imem_rdata <= ram_model[fetch_addr];
            end else begin
                vif.imem_rdata <= 32'h00000013; // Fallback to safe RV32I NOP (addi x0, x0, 0)
            end
            vif.imem_ready <= 1'b1;
        end else begin
            vif.imem_ready <= 1'b0;
        end

        // Handle data memory phase if core requests read/write (for future phases)
        if (vif.dmem_req === 1'b1) begin
            // Placeholder protocol logic for DMEM transactions
            vif.dmem_ready <= 1'b1;
        end else begin
            vif.dmem_ready <= 1'b0;
        end
    endtask : drive_transaction

    // -------------------------------------------------------------------------
    // Backdoor Testing Utilities
    // -------------------------------------------------------------------------

    // Backdoor task to parse a text-based hex memory map file (smoke.mem)
    // Directly pre-fills the virtual RAM array bypassing bus timing.
    virtual task load_backdoor_memory(string file_path);
        `uvm_info("DRV_BACKDOOR", $sformatf("Loading factory binary from: %s",
                                            file_path), UVM_LOW)
        $readmemh(file_path, ram_model);
    endtask : load_backdoor_memory

endclass : mem_driver

`endif  // MEM_DRIVER_SV
