#!/usr/bin/env bash

# =============================================================================
# Project:         riscv-core
# File:            run_regression.sh
# Description:     Consolidated simulation execution script for Phase 1, Phase 2,
#                  and Phase 3 test validations using Verilator.
# =============================================================================

# Exit immediately if a command exits with a non-zero status
set -e

echo "================================================================="
echo " Starting Full Verification Regression Stack"
echo "================================================================="

# -------------------------------------------------------------------------
# Step 1: Compilation Phase (Verilate & Compile Source Trees)
# -------------------------------------------------------------------------
echo "[BUILD] Verilating RTL and UVM Testbench Environment..."

verilator --binary \
          -Wall \
          -sv \
          --timing \
          -I../dv \
          -I../dv/env \
          -I../dv/tests \
          ../dv/riscv_types_pkg.sv \
          ../dv/env/core_env.sv \
          ../dv/tests/core_base_test.sv \
          ../dv/tests/test_smoke.sv \
          ../dv/tests/test_hazards.sv \
          ../dv/core_tb.sv \
          --top-module core_tb \
          -o obj_dir/Vcore_sim

echo "[BUILD] Compilation successful. Binary generated at obj_dir/Vcore_sim."
echo ""

# -------------------------------------------------------------------------
# Step 2: Phase 1 - Directed Assembly Smoke Tests
# -------------------------------------------------------------------------
echo "-----------------------------------------------------------------"
echo " Running Phase 1: Directed Smoke Tests"
echo "-----------------------------------------------------------------"

echo "[RUN] Executing Phase 1 Base Smoke Test (Straight-Line)..."
./obj_dir/Vcore_sim +UVM_TESTNAME=test_smoke +MEM_FILE=smoke.mem

echo "[RUN] Executing Phase 1 Expanded Test (Full Supported Instruction Matrix)..."
./obj_dir/Vcore_sim +UVM_TESTNAME=test_smoke +MEM_FILE=smoke_expanded.mem
echo ""

# -------------------------------------------------------------------------
# Step 3: Phase 2 - Structural Pipeline Hazard Stress Tests
# -------------------------------------------------------------------------
echo "-----------------------------------------------------------------"
echo " Running Phase 2: Pipeline Hazard Stress Tests"
echo "-----------------------------------------------------------------"

echo "[RUN] Stressing RAW Data Hazards (Forwarding paths validation)..."
./obj_dir/Vcore_sim +UVM_TESTNAME=test_hazards +HAZARD_TYPE=hazard_raw.mem

echo "[RUN] Stressing Load-Use Hazards (HDU Interlock stall tracking)..."
./obj_dir/Vcore_sim +UVM_TESTNAME=test_hazards +HAZARD_TYPE=hazard_load.mem

echo "[RUN] Stressing Control Flow Hazards (Branch flush/clear handling)..."
./obj_dir/Vcore_sim +UVM_TESTNAME=test_hazards +HAZARD_TYPE=hazard_control.mem
echo ""

# -------------------------------------------------------------------------
# Step 4: Phase 3 - Freestanding Compiled C Programs
# -------------------------------------------------------------------------
echo "-----------------------------------------------------------------"
echo " Running Phase 3: Bare-Metal C Runtime Executions"
echo "-----------------------------------------------------------------"

# Verify compilation toolchain assets exist prior to running cross-compilation
if ! command -v riscv64-unknown-elf-gcc &> /dev/null; then
    echo "[WARN] riscv64-unknown-elf-gcc could not be found."
    echo "[WARN] Skipping C cross-compilation. Attempting to run existing c_runtime.mem..."
else
    echo "[COMPILER] Cross-compiling C source to RV32I targets..."
    sh compile.sh
    echo "[COMPILER] Code array successfully formatted into c_runtime.mem."
fi

echo "[RUN] Executing Phase 3 C-compiled algorithmic payload..."
./obj_dir/Vcore_sim +UVM_TESTNAME=test_c_runtime +MEM_FILE=c_runtime.mem

echo ""
echo "================================================================="
echo " All Phase Regressions Executed Safely!"
echo "================================================================="

# -------------------------------------------------------------------------
# Step 4: Phase 4 - Randomized Instruction Stream Tests
# -------------------------------------------------------------------------
echo "[RUN] Executing Phase 4 Randomized Instruction Stream Tests..."
./obj_dir/Vcore_sim +UVM_TESTNAME=test_random