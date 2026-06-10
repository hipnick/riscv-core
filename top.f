# RTL Package
rtl/common/riscv_types_pkg.sv

# RTL leaf modules
rtl/ex/alu/alu.sv
rtl/ex/agu/agu.sv
rtl/ex/bc/bc.sv
rtl/ex/fwd/fwd.sv
rtl/id/cu/cu.sv
rtl/id/hdu/hdu.sv
rtl/id/imm_gen/imm_gen.sv
rtl/id/rf/rf.sv
rtl/if/btb/btb.sv
rtl/if/imem/imem.sv
rtl/if/pc/pc.sv
rtl/mem/lsu/lsu.sv
rtl/wb/wb_mux/wb_mux.sv

# RTL pipeline registers
rtl/pr/if_id/pr_if_id.sv
rtl/pr/id_ex/pr_id_ex.sv
rtl/pr/ex_mem/pr_ex_mem.sv
rtl/pr/mem_wb/pr_mem_wb.sv

# RTL stage wrappers
rtl/if/if_stage.sv
rtl/id/id_stage.sv
rtl/ex/ex_stage.sv
rtl/mem/mem_stage.sv
rtl/wb/wb_stage.sv

# RTL top
rtl/core_top.sv

# DV include directories
+incdir+dv
+incdir+dv/env
+incdir+dv/env/memory_agent
+incdir+dv/tests
+incdir+dv/env/sequences

# DV interface
dv/core_if.sv

# DV package (transaction type only)
dv/env/core_env_pkg.sv

# DV UVM components (file-scoped, dependency order)
dv/env/memory_agent/mem_monitor.sv
dv/env/memory_agent/mem_driver.sv
dv/env/memory_agent/mem_sequencer.sv
dv/env/core_scoreboard.sv
dv/env/memory_agent/imem_dmem_agent.sv
dv/env/core_env.sv

# DV sequences
dv/env/sequences/core_base_seq.sv
dv/env/sequences/random_instr_seq.sv

# DV tests
dv/tests/core_base_test.sv
dv/tests/test_smoke.sv
dv/tests/test_hazards.sv
dv/tests/test_c_runtime.sv
dv/tests/test_random.sv

# DV testbench top
dv/core_tb.sv
