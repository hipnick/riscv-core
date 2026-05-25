// =============================================================================
// Project:         riscv-core
// File:            mem_driver.sv
//
// Description:     UVM driver that maps transaction packets into accurate 
//                  pin transitions via core_if.driver modport.
// =============================================================================

`ifndef MEM_DRIVER_SV
`define MEM_DRIVER_SV

class mem_driver extends uvm_driver #(riscv_instr_tx);
    `uvm_component_utils(mem_driver)

    // Virtual interface handle bound to driver modport
    virtual core_if.driver vif;

    // Associative memory model array
    protected data_t ram_model[data_t];

    function new(string name = "mem_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual core_if.driver)::get(
                this, "", "vif", vif
            )) begin
            `uvm_fatal("DRV_NO_VIF",
                       "Virtual interface driver modport handle not found")
        end
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
        reset_signals();
        wait (vif.rst_n === 1'b1);

        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask : run_phase

    protected task reset_signals();
        // Clear pins via the clocking block to assert initial idle conditions
        vif.drv_cb.imem_rdata <= '0;
        vif.drv_cb.imem_valid <= 1'b0;
        vif.drv_cb.dmem_rdata <= '0;
        vif.drv_cb.dmem_valid <= 1'b0;
    endtask : reset_signals

    protected task drive_transaction(riscv_instr_tx tx);
        // Synchronize on the driver clocking block event edge
        @(vif.drv_cb);

        // Example bus driving orchestration utilizing the modport signals
        // You will read input pins via: vif.drv_cb.imem_addr
        // You will update output pins via: vif.drv_cb.imem_rdata <= ...
    endtask : drive_transaction

    virtual task load_backdoor_memory(string file_path);
        // Robust custom parsing mechanism to populate associative ram_model array goes here
    endtask : load_backdoor_memory

endclass : mem_driver

`endif  // MEM_DRIVER_SV
