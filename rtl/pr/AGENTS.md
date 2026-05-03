### 6. Pipeline Registers (Support Modules)

The Pipeline Registers consists of the synchronous boundary registers and control logic required to transform a combinational 5-stage design into a cycle-accurate pipelined processor. These modules ensure data integrity as instructions progress from Fetch to Writeback.

- **Pipeline Registers (PR):** 
    - **Physical Role:** Acts as the "State" between stages. Each register captures the output of the preceding stage on the rising edge of the clock.
    - **Control Signals:** Each register supports `stall_i` (to freeze the pipeline) and `flush_i` (to clear the pipeline in the event of a branch misprediction).
    - **Software Analogy:** This is the hardware equivalent of a Redux store or React state update that occurs on every "heartbeat" (clock cycle).
    - **Modules:** `pr_if_id`, `pr_id_ex`, `pr_ex_mem`, `pr_mem_wb`.
- **Hazard Detection Unit (HDU):** 
    - **Logic:** Currently located in `rtl/id/hdu/`. It monitors instruction dependencies to identify "Use-After-Load" scenarios.
    - **Action:** Generates stall signals for the `IF/ID` register and the Program Counter to allow memory data to arrive before the dependent instruction executes.
- **Forwarding Unit:** 
    - **Logic:** Currently located in `rtl/ex/fwd/`. Monitors the destination registers in the `EX/MEM` and `MEM/WB` stages.
    - **Action:** Dynamically routes data directly to the ALU inputs if the current `ID/EX` instruction depends on a result that hasn't been written to the Register File yet.