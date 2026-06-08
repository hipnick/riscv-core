# =============================================================================
# Project:         riscv-core
# File:            crt0.s
# Description:     C Runtime Start execution bootstrap hook. Setup the stack
#                  pointer framework prior to branching into main application loops.
# =============================================================================

.section .text.init
.global _start

_start:
    # Disable global interrupts or register states if applicable
    .option push
    .option norelax
    la sp, _stack_top    # Load stack memory pointer address defined by linker.ld
    .option pop

    # Call the application primary entry function
    jal ra, main

_end_loop:
    # Trap pipeline execution into a permanent loop upon main function termination
    j _end_loop