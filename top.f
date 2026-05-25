# Package (must be first)
rtl/common/riscv_types_pkg.sv

# Sub-modules (leaf modules - no dependencies on other RTL)
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

# Pipeline Registers
rtl/pr/if_id/pr_if_id.sv
rtl/pr/id_ex/pr_id_ex.sv
rtl/pr/ex_mem/pr_ex_mem.sv
rtl/pr/mem_wb/pr_mem_wb.sv

# Stage Wrappers (depend on sub-modules)
rtl/if/if_stage.sv
rtl/id/id_stage.sv
rtl/ex/ex_stage.sv
rtl/mem/mem_stage.sv
rtl/wb/wb_stage.sv


# Top-level
+incdir+dv
+incdir+dv/env
+incdir+dv/env/memory_agent
rtl/core_top.sv
dv/core_if.sv
dv/env/core_env_pkg.sv
dv/core_tb.sv