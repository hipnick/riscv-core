# RISC-V Core Simulation Setup

## Prerequisites

- Verilator 5.042+ (submodule at `sim/verilator`, commit `184f8f7920c1bf24e3d13783db8268484992b61f`)
- UVM 1800.2-2017-1.0 (at `dv/uvm/1800.2-2017-1.0/src`)
- RISC-V GCC cross-compiler (for Phase 3 C tests)

## Building Verilator

Verilator is included as a git submodule. To build it:

```bash
cd sim/verilator
autoconf
./configure
make -j$(nproc)
```

The binary will be at `sim/verilator/bin/verilator`.

## Running the Regression

```bash
cd /home/gokhan/projects/riscv-core
./sim/run_regression.sh
```

Or to compile and run manually:

```bash
export UVM_HOME=$(pwd)/dv/uvm/1800.2-2017-1.0/src
./sim/verilator/bin/verilator --binary -j 1 \
    -Wno-fatal -Wno-WIDTHTRUNC -Wno-WIDTH \
    --top-module core_tb \
    +incdir+"$UVM_HOME" \
    +define+UVM_NO_DPI \
    +incdir+rtl/common +incdir+rtl \
    +incdir+dv +incdir+dv/env +incdir+dv/env/memory_agent \
    -f top.f \
    "$UVM_HOME"/uvm_pkg.sv

# Run a specific test:
./obj_dir/Vcore_tb +UVM_TESTNAME=test_smoke
```

## Test Cases

| Phase | Command |
|-------|---------|
| Smoke (straight-line) | `+UVM_TESTNAME=test_smoke +MEM_FILE=sim/smoke.mem` |
| Hazards | `+UVM_TESTNAME=test_hazards` |
| C Runtime | `+UVM_TESTNAME=test_c_runtime` |
| Random | `+UVM_TESTNAME=test_random` |

## Known Verilator Issues

- **Variable/Type name shadowing**: Do NOT use the same name for a variable as its type (e.g., `imem_dmem_agent imem_dmem_agent;`). Verilator 5.042 cannot resolve the type in this case. Use a distinct variable name (e.g., `imem_dmem_agent agent;`).
- **`uvm_top` not found**: Use `uvm_root::get()` instead of `uvm_top` in Verilator compilations.

## File Organization

- `top.f`: File list for Verilator compilation
- `run_regression.sh`: Full regression script
- `obj_dir/Vcore_tb`: Compiled simulator binary
