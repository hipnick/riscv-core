#!/usr/bin/env bash

# =============================================================================
# Project:         riscv-core
# File:            run_regression.sh
# Description:     Consolidated simulation execution script for Phase 1, Phase 2,
#                  Phase 3, and Phase 4 test validations using Verilator.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJ_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VERILATOR_DIR="$SCRIPT_DIR/verilator"
VERILATOR_BIN="$VERILATOR_DIR/bin/verilator"
UVM_HOME="$PROJ_DIR/dv/uvm/1800.2-2017-1.0/src"

echo "================================================================="
echo " Starting Full Verification Regression Stack"
echo "================================================================="

# -------------------------------------------------------------------------
# Step 1: Compilation Phase (Verilate & Compile Source Trees)
# -------------------------------------------------------------------------
echo "[BUILD] Verilating RTL and UVM Testbench Environment..."
echo "        Verilator : $VERILATOR_BIN"
echo "        UVM_HOME  : $UVM_HOME"
echo ""

cd "$PROJ_DIR"

$VERILATOR_BIN --trace --trace-structs --binary -j 1 \
    -Wno-fatal -Wno-WIDTHTRUNC -Wno-WIDTH \
    --top-module core_tb \
    +incdir+"$UVM_HOME" \
    +define+UVM_NO_DPI \
    +incdir+"$PROJ_DIR"/rtl/common \
    +incdir+"$PROJ_DIR"/rtl \
    +incdir+"$PROJ_DIR"/dv \
    +incdir+"$PROJ_DIR"/dv/env \
    +incdir+"$PROJ_DIR"/dv/env/memory_agent \
    -f "$PROJ_DIR/top.f" \
    "$UVM_HOME"/uvm_pkg.sv

echo "[BUILD] Compilation successful. Binary generated at obj_dir/Vcore_tb."
echo ""

# -------------------------------------------------------------------------
# Step 2: Phase 1 - Directed Assembly Smoke Tests
# -------------------------------------------------------------------------
echo "-----------------------------------------------------------------"
echo " Running Phase 1: Directed Smoke Tests"
echo "-----------------------------------------------------------------"

echo "[RUN] Executing Phase 1 Base Smoke Test (Straight-Line)..."
./obj_dir/Vcore_tb +UVM_TESTNAME=test_smoke +MEM_FILE="$SCRIPT_DIR/smoke.mem"

echo "[RUN] Executing Phase 1 Expanded Test (Full Supported Instruction Matrix)..."
./obj_dir/Vcore_tb +UVM_TESTNAME=test_smoke +MEM_FILE="$SCRIPT_DIR/smoke_expanded.mem"
echo ""

# -------------------------------------------------------------------------
# Step 3: Phase 2 - Structural Pipeline Hazard Stress Tests
# -------------------------------------------------------------------------
echo "-----------------------------------------------------------------"
echo " Running Phase 2: Pipeline Hazard Stress Tests"
echo "-----------------------------------------------------------------"

echo "[RUN] Stressing RAW Data Hazards (Forwarding paths validation)..."
./obj_dir/Vcore_tb +UVM_TESTNAME=test_hazards +HAZARD_TYPE="$SCRIPT_DIR/hazard_raw.mem"

echo "[RUN] Stressing Load-Use Hazards (HDU Interlock stall tracking)..."
./obj_dir/Vcore_tb +UVM_TESTNAME=test_hazards +HAZARD_TYPE="$SCRIPT_DIR/hazard_load.mem"

echo "[RUN] Stressing Control Flow Hazards (Branch flush/clear handling)..."
./obj_dir/Vcore_tb +UVM_TESTNAME=test_hazards +HAZARD_TYPE="$SCRIPT_DIR/hazard_control.mem"
echo ""

# -------------------------------------------------------------------------
# Step 4: Phase 3 - Freestanding Compiled C Programs
# -------------------------------------------------------------------------
echo "-----------------------------------------------------------------"
echo " Running Phase 3: Bare-Metal C Runtime Executions"
echo "-----------------------------------------------------------------"

if ! command -v riscv64-unknown-elf-gcc &> /dev/null; then
    echo "[WARN] riscv64-unknown-elf-gcc could not be found."
    echo "[WARN] Skipping C cross-compilation. Attempting to run existing c_runtime.mem..."
else
    echo "[COMPILER] Cross-compiling C source to RV32I targets..."
    (cd "$SCRIPT_DIR" && sh compile.sh)
    echo "[COMPILER] Code array successfully formatted into c_runtime.mem."
fi

echo "[RUN] Executing Phase 3 C-compiled algorithmic payload..."
./obj_dir/Vcore_tb +UVM_TESTNAME=test_c_runtime +MEM_FILE="$SCRIPT_DIR/c_runtime.mem"

echo ""
echo "================================================================="
echo " All Phase Regressions Executed Safely!"
echo "================================================================="

# -------------------------------------------------------------------------
# Step 4: Phase 4 - Randomized Instruction Stream Tests
# -------------------------------------------------------------------------
echo "[RUN] Executing Phase 4 Randomized Instruction Stream Tests..."
./obj_dir/Vcore_tb +UVM_TESTNAME=test_random
