# 1. Compile C code and Assembly bootstrapping routine into an ELF binary machine format
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -ffreestanding -nostdlib \
                        -O2 -T linker.ld crt0.s main.c -o c_program.elf

# 2. Extract pure raw binary bytecode data strips from the ELF packaging layer
riscv64-unknown-elf-objcopy -O binary c_program.elf c_program.bin

# 3. Format raw binary blocks into a 32-bit width clean Hex text string file
od -An -v -tx4 -w4 c_program.bin | sed 's/ //g' > c_runtime.mem