
##############
# HOW TO USE #
##############

# I am using x86_64 and installed cross compilers
# aarch64:
# sudo apt-get install gcc-aarch64-linux-gnu libc-dev-aarch64-cross
# riscv64:
# sudo apt-get install gcc-riscv64-linux-gnu libc-dev-riscv64-cross

# I also installed qemu to interpret the cross-compiled elf binaries
# aarch64:
# sudo apt-get install qemu
# riscv64:
# I followed instructions: https://wiki.debian.org/RISC-V#Qemu
#  special notes
#   config tells you to install things like: libglib2.0-dev libpixman-1-dev
#   don't cp qemu-riscv64 to /usr/bin/qemu-riscv64-static, just call it directly by setting the following path to it


export QEMU_RISCV64_DIR := ~/repos/qemu/qemu_riscv/riscv64-linux-user/
# for completeness, also have empty path for aarch64, change as needed
export QEMU_AARCH64_DIR := 






##########
# x86_64 #
##########


blake2b_x86_64:
	gcc -std=c99 blake2b.c blake2b.x86_64.S -o blake2b.x86_64.elf -fno-pie -no-pie -DBENCHMARK=0 -DCOUNT_CYCLES_X86_64=1
	./blake2b.x86_64.elf 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa 0x733f2ea68641aaf7f47616f6734612a544ff6dd03213ec8b949303ca29b8159eed9d1b838e051906997c15203d4f9a569b33826fe6bfb439ebd1efd46903986d





###########
# riscv64 #
###########

blake2b_riscv64:
	riscv64-linux-gnu-gcc -std=c99 blake2b.c blake2b.riscv64.S -o blake2b.riscv64.elf -static -fno-pie -no-pie -DBENCHMARK=0 -DCOUNT_CYCLES_X86_64=0
	${QEMU_RISCV64_DIR}qemu-riscv64 blake2b.riscv64.elf 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa 0x733f2ea68641aaf7f47616f6734612a544ff6dd03213ec8b949303ca29b8159eed9d1b838e051906997c15203d4f9a569b33826fe6bfb439ebd1efd46903986d



clean:
	rm *.elf
