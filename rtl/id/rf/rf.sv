// =============================================================================
// Project:         riscv-core
// File:            rf.sv
//
// Description:     Dual-port read, single-port write Register File (RF).
//                  Contains 32 general-purpose registers where x0 is 
//                  hardwired to zero.
//
// Dependencies:    riscv_types_pkg.sv
//
// License:         Apache-2.0
// =============================================================================

`default_nettype none

module rf
    import riscv_types_pkg::*;
(
    input wire      clk_i,
    input wire      rst_ni,
    // Read Port 1
    input address_t rs1_addr_i,
    // Read Port 2
    input address_t rs2_addr_i,
    // Write Port (Typically from WB stage)
    input address_t rd_addr_i,
    input data_t    rd_data_i,
    input wire      rd_we_i,

    output data_t rs1_data_o,
    output data_t rs2_data_o
);

    // ---------------------------------------------------------------------------
    // Internal State
    // ---------------------------------------------------------------------------
    logic [DATA_WIDTH-1:0] rf_reg[NUM_REGISTERS];

    // ---------------------------------------------------------------------------
    // Read Logic (Asynchronous)
    // ---------------------------------------------------------------------------
    // RISC-V Requirement: x0 is always 0.
    assign rs1_data_o = (rs1_addr_i == '0) ? '0 : rf_reg[rs1_addr_i];
    assign rs2_data_o = (rs2_addr_i == '0) ? '0 : rf_reg[rs2_addr_i];

    // ---------------------------------------------------------------------------
    // Write Logic (Synchronous)
    // ---------------------------------------------------------------------------
    always_ff @(posedge clk_i or negedge rst_ni) begin : proc_rf_write
        if (!rst_ni) begin
            for (int i = 0; i < NUM_REGISTERS; i++) begin
                rf_reg[i] <= '0;
            end
        end else if (rd_we_i && (rd_addr_i != '0)) begin
            rf_reg[rd_addr_i] <= rd_data_i;
        end
    end

endmodule : rf
