/* =============================================================================
   Project:         riscv-core
   File:            linker.ld
   Description:     Custom minimalist linker script mapping text/data sections
                    to start exactly at memory address 0x00000000.
   ============================================================================= */

OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
  /* Map instruction memory layout starting at execution reset vector location */
  . = 0x00000000;
  .text : {
    *(.text.init)    /* Guarantees crt0.s boot hook executes first */
    *(.text)
    *(.text.*)
  }

  /* Align data memory boundaries to 4-byte words */
  . = ALIGN(4);
  .rodata : { *(.rodata) *(.rodata.*) }
  .data   : { *(.data)   *(.data.*)   }
  .bss    : { *(.bss)    *(.bss.*)    }

  /* Set stack pointer boundary to the absolute ceiling limit of your memory model array */
  _stack_top = 0x00001000; 
}