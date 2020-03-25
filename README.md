
This is an experiment to accurately predict runtime of programs by counting cycles on open hardware. We know that predicting runtime of arbitrary code is [undecidable](https://en.wikipedia.org/wiki/Rice's_theorem) for a Turing complete language, so our predictions will be for programs which can be syntactically guaranteed to execute a fixed sequence of opcodes.



# Dependencies

No special hardware needed, we simulate execution in software.

I am using x86_64. I installed cross compilers.

```
# aarch64:
sudo apt-get install gcc-aarch64-linux-gnu libc-dev-aarch64-cross
# riscv64:
sudo apt-get install gcc-riscv64-linux-gnu libc-dev-riscv64-cross
```

I also installed qemu to interpret the cross-compiled elf binaries.

```
# for aarch64:
sudo apt-get install qemu

# for riscv64:
# I followed instructions: https://wiki.debian.org/RISC-V#Qemu
#  special notes:
#   - config told me to install things like: libglib2.0-dev libpixman-1-dev
#   - don't cp qemu-riscv64 to /usr/bin/qemu-riscv64-static, just call it directly by setting the path to it in the Makefile
```



# Execute

Before executing, adjust paths at top of `Makefile`.

```
make blake2b_riscv64
make blake2b_x86_64
make mul256x256_aarch64
make mul256x256_riscv64
make mul256x256_x86_64
make mul256x256_wasm32
```




# Cycle Counts

We use [BOOM](https://github.com/riscv-boom/riscv-boom) hardware description for now. Simulated hardware speed is around 20 cycles/second. To execute, we copied the assembly into a custom tester on which we can count cycles, we will publish this custom tester soon. For now, we give initial numbers baseline naive but correct implementations, optimizations are possible to get these numbers lower.

```
blake2b_riscv64.elf			15715 cycles on BOOM
mul256x256_256_64bitlimbs.riscv64.elf	415 cycles on BOOM
mul256x256_512_64bitlimbs.riscv64.elf	967 cycles on BOOM
```
