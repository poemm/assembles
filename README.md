
This is an experiment to accurately predict runtime of programs by counting cycles on open hardware. We know that predicting runtime of arbitrary code is undecidable for a Turing complete language, so our predictions will be for programs which can be syntactically guaranteed to execute a fixed sequence of opcodes.



# Dependencies

No special hardware needed, we simulate execution on hardware descriptions -- simulated hardware speed is around 20 cycles/second.

I am using x86_64 and installed cross compilers.

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
#   - don't cp qemu-riscv64 to /usr/bin/qemu-riscv64-static, just call it directly by setting the following path to it
```

Hardware descriptions.
We use [BOOM](https://github.com/riscv-boom/riscv-boom).


# Execute

```
make blake2b_riscv64
make blake2b_x86_64
```

TODO: Execute on an open hardware description like BOOM, counting cycles. We had to hand modify assembly and add custom assembly code. Need way to automate this.



# Cycle Counts

Initial results are as follows. There are optimizations which will lower this number.

```
blake2b_riscv64.elf	15715 cycles on BOOM
```
