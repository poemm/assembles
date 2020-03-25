


# SET THESE VARIABLES FOR YOUR COMPUTER

export QEMU_RISCV64_DIR := ~/repos/qemu/qemu_riscv/riscv64-linux-user/
# for completeness, also have empty path for aarch64, change as needed, empty if using instructions in the README
export QEMU_AARCH64_DIR := 

# for wasm, need path to wabt
export WABT_DIR := ~/repos/wabt/wabt-1.0.13/



####################
# BLAKE2B Compress #
####################

blake2b_x86_64:
	gcc -std=c99 blake2b.c blake2b.x86_64.S -o blake2b.x86_64.elf -fno-pie -no-pie -DBENCHMARK=0 -DCOUNT_CYCLES_X86_64=1
	./blake2b.x86_64.elf 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa 0x733f2ea68641aaf7f47616f6734612a544ff6dd03213ec8b949303ca29b8159eed9d1b838e051906997c15203d4f9a569b33826fe6bfb439ebd1efd46903986d

blake2b_riscv64:
	riscv64-linux-gnu-gcc -std=c99 blake2b.c blake2b.riscv64.S -o blake2b.riscv64.elf -static -fno-pie -no-pie -DBENCHMARK=0 -DCOUNT_CYCLES_X86_64=0
	${QEMU_RISCV64_DIR}qemu-riscv64 blake2b.riscv64.elf 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa 0x733f2ea68641aaf7f47616f6734612a544ff6dd03213ec8b949303ca29b8159eed9d1b838e051906997c15203d4f9a569b33826fe6bfb439ebd1efd46903986d





##########
# mul256 #
##########


# x86_64

mul256x256_x86_64: mul256x256_256__x86_64 mul256x256_512__x86_64

mul256x256_256__x86_64: mul256x256_256__x86_64__32bitlimbs mul256x256_256__x86_64__64bitlimbs mul256x256_256__x86_64__64bitlimbs__adc

mul256x256_512__x86_64: mul256x256_512__x86_64__32bitlimbs mul256x256_512__x86_64__64bitlimbs mul256x256_512__x86_64__64bitlimbs__adc


mul256x256_256__x86_64__32bitlimbs: mul256x256_256__x86_64__32bitlimbs__test mul256x256_256__x86_64__32bitlimbs__bench

mul256x256_256__x86_64__32bitlimbs__test:
	gcc -std=c99 mul256x256.c mul256x256_256_32bitlimbs.x86_64.s -o mul256x256_256_32bitlimbs.x86_64.elf -fno-pie -no-pie -DBENCHMARK=0 -DTO512=0 -DCOUNT_CYCLES_X86_64=1
	./mul256x256_256_32bitlimbs.x86_64.elf 0xb01a4eb663de65800f887e119472773b95a7741e40b2f0ae0474dd4e8a86d50a 0xd53da44fb796edbba4c3fed12cc0835e080c1b040fb3572a90811a3f39fd46d1 0x3da16000fc67be8ec41d528f74311ab631e6e25a1d1defdf8e3e8525bb36a92a

mul256x256_256__x86_64__32bitlimbs__bench:
	gcc -std=c99 mul256x256.c mul256x256_256_32bitlimbs.x86_64.s -o mul256x256_256_32bitlimbs_bench.x86_64.elf -fno-pie -no-pie -DBENCHMARK=1 -DTO512=0
	time ./mul256x256_256_32bitlimbs_bench.x86_64.elf


mul256x256_512__x86_64__32bitlimbs: mul256x256_512__x86_64__32bitlimbs__test mul256x256_512__x86_64__32bitlimbs__bench

mul256x256_512__x86_64__32bitlimbs__test:
	gcc -std=c99 mul256x256.c mul256x256_512_32bitlimbs.x86_64.s -o mul256x256_512_32bitlimbs.x86_64.elf -fno-pie -no-pie -DBENCHMARK=0 -DTO512=1 -DCOUNT_CYCLES_X86_64=1
	./mul256x256_512_32bitlimbs.x86_64.elf 0xdfb7ce8d11eec556bcd0b009b8100dfc8c2c673fec41059799f4a044302439e 0x6e1caa7a0fb83615d8271104e6ed3afb720978b0188cb269d3e3c37b7add23dc 0x603a07d5efa16c868b70c5dfbc240b6fc28eed7ea44ee460e639bb605164be7bee36a6db7700c37d08bff85c58f665d2385a5fd4333dff05450f4ea9096b5c8

mul256x256_512__x86_64__32bitlimbs__bench:
	gcc -std=c99 mul256x256.c mul256x256_512_32bitlimbs.x86_64.s -o mul256x256_512_32bitlimbs_bench.x86_64.elf -fno-pie -no-pie -DBENCHMARK=1 -DTO512=1
	time ./mul256x256_512_32bitlimbs_bench.x86_64.elf


mul256x256_256__x86_64__64bitlimbs: mul256x256_256__x86_64__64bitlimbs__test mul256x256_256__x86_64__64bitlimbs__bench

mul256x256_256__x86_64__64bitlimbs__test:
	gcc -std=c99 mul256x256.c mul256x256_256_64bitlimbs.x86_64.s -o mul256x256_256_64bitlimbs.x86_64.elf -fno-pie -no-pie -DBENCHMARK=0 -DTO512=0 -DCOUNT_CYCLES_X86_64=1
	./mul256x256_256_64bitlimbs.x86_64.elf 0xb01a4eb663de65800f887e119472773b95a7741e40b2f0ae0474dd4e8a86d50a 0xd53da44fb796edbba4c3fed12cc0835e080c1b040fb3572a90811a3f39fd46d1 0x3da16000fc67be8ec41d528f74311ab631e6e25a1d1defdf8e3e8525bb36a92a

mul256x256_256__x86_64__64bitlimbs__bench:
	gcc -std=c99 mul256x256.c mul256x256_256_64bitlimbs.x86_64.s -o mul256x256_256_64bitlimbs_bench.x86_64.elf -fno-pie -no-pie -DBENCHMARK=1 -DTO512=0
	time ./mul256x256_256_64bitlimbs_bench.x86_64.elf


mul256x256_512__x86_64__64bitlimbs: mul256x256_512__x86_64__64bitlimbs__test mul256x256_512__x86_64__64bitlimbs__bench

mul256x256_512__x86_64__64bitlimbs__test:
	gcc -std=c99 mul256x256.c mul256x256_512_64bitlimbs.x86_64.s -o mul256x256_512_64bitlimbs.x86_64.elf -fno-pie -no-pie -DBENCHMARK=0 -DTO512=1 -DCOUNT_CYCLES_X86_64=1
	./mul256x256_512_64bitlimbs.x86_64.elf 0xdfb7ce8d11eec556bcd0b009b8100dfc8c2c673fec41059799f4a044302439e 0x6e1caa7a0fb83615d8271104e6ed3afb720978b0188cb269d3e3c37b7add23dc 0x603a07d5efa16c868b70c5dfbc240b6fc28eed7ea44ee460e639bb605164be7bee36a6db7700c37d08bff85c58f665d2385a5fd4333dff05450f4ea9096b5c8

mul256x256_512__x86_64__64bitlimbs__bench:
	gcc -std=c99 mul256x256.c mul256x256_512_64bitlimbs.x86_64.s -o mul256x256_512_64bitlimbs_bench.x86_64.elf -fno-pie -no-pie -DBENCHMARK=1 -DTO512=1
	time ./mul256x256_512_64bitlimbs_bench.x86_64.elf


mul256x256_256__x86_64__64bitlimbs__adc: mul256x256_256__x86_64__64bitlimbs__adc__test mul256x256_256__x86_64__64bitlimbs__adc__bench

mul256x256_256__x86_64__64bitlimbs__adc__test:
	gcc -std=c99 mul256x256.c mul256x256_256_64bitlimbs_adc.x86_64.s -o mul256x256_256_64bitlimbs_adc.x86_64.elf -fno-pie -no-pie -DBENCHMARK=0 -DTO512=0 -DCOUNT_CYCLES_X86_64=1
	./mul256x256_256_64bitlimbs_adc.x86_64.elf 0xb01a4eb663de65800f887e119472773b95a7741e40b2f0ae0474dd4e8a86d50a 0xd53da44fb796edbba4c3fed12cc0835e080c1b040fb3572a90811a3f39fd46d1 0x3da16000fc67be8ec41d528f74311ab631e6e25a1d1defdf8e3e8525bb36a92a

mul256x256_256__x86_64__64bitlimbs__adc__bench:
	gcc -std=c99 mul256x256.c mul256x256_256_64bitlimbs_adc.x86_64.s -o mul256x256_256_64bitlimbs_adc_bench.x86_64.elf -fno-pie -no-pie -DBENCHMARK=1 -DTO512=0
	time ./mul256x256_256_64bitlimbs_adc_bench.x86_64.elf


mul256x256_512__x86_64__64bitlimbs__adc: mul256x256_512__x86_64__64bitlimbs__adc__test mul256x256_512__x86_64__64bitlimbs__adc__bench

mul256x256_512__x86_64__64bitlimbs__adc__test:
	gcc -std=c99 mul256x256.c mul256x256_512_64bitlimbs_adc.x86_64.s -o mul256x256_512_64bitlimbs_adc.x86_64.elf -fno-pie -no-pie -DBENCHMARK=0 -DTO512=1 -DCOUNT_CYCLES_X86_64=1
	./mul256x256_512_64bitlimbs_adc.x86_64.elf 0xdfb7ce8d11eec556bcd0b009b8100dfc8c2c673fec41059799f4a044302439e 0x6e1caa7a0fb83615d8271104e6ed3afb720978b0188cb269d3e3c37b7add23dc 0x603a07d5efa16c868b70c5dfbc240b6fc28eed7ea44ee460e639bb605164be7bee36a6db7700c37d08bff85c58f665d2385a5fd4333dff05450f4ea9096b5c8

mul256x256_512__x86_64__64bitlimbs__adc__bench:
	gcc -std=c99 mul256x256.c mul256x256_512_64bitlimbs_adc.x86_64.s -o mul256x256_512_64bitlimbs_adc_bench.x86_64.elf -fno-pie -no-pie -DBENCHMARK=1 -DTO512=1
	time ./mul256x256_512_64bitlimbs_adc_bench.x86_64.elf



# aarch64

mul256x256_aarch64: mul256x256_256__aarch64__32bitlimbs mul256x256_512__aarch64__32bitlimbs

mul256x256_256__aarch64__32bitlimbs:
	aarch64-linux-gnu-gcc -std=c99 mul256x256.c mul256x256_256_32bitlimbs.aarch64.s -o mul256x256_256_32bitlimbs.aarch64.elf -fno-pie -no-pie -static -DBENCHMARK=0 -DTO512=0
	${QEMU_AARCH64_DIR}qemu-aarch64 mul256x256_256_32bitlimbs.aarch64.elf 0xd90f675dd71ca7cff8751d0a2e0df326d786d2ab3e60426e94d2af91fd429bd5 0x28095d41b0cb61d0786abe03193a28b50e8e143d0455ede68d5dfb7e1f64e74c 0x16270d9cb85a493a640c1a8ddfc59aa6c2ac1b47ffef973d709e6397f497763c

mul256x256_512__aarch64__32bitlimbs:
	aarch64-linux-gnu-gcc -std=c99 mul256x256.c mul256x256_512_32bitlimbs.aarch64.s -o mul256x256_512_32bitlimbs.aarch64.elf -fno-pie -no-pie -static -DBENCHMARK=0 -DTO512=1
	${QEMU_AARCH64_DIR} qemu-aarch64 mul256x256_512_32bitlimbs.aarch64.elf 0xb52bdad09bb3e876cde742321429519146ad656c978b81f02c87ab2ef15680d4 0xa7667afac732eb0bddd4909a7c30bdd41243e26cb07faf3f0b32db5b40b37b9c 0x7678223fa4c4a04077a5fbc237667d391bd08a0706bc3a79e097a1903e3ca88c9b7b334c9c4570565fc6ff0de3c571d10f1aeac9cd3e1e27cf71659cb4d85d30




# riscv64

mul256x256_riscv64: mul256x256_256__riscv64 mul256x256_512__riscv64

mul256x256_256__riscv64: mul256x256_256__riscv64__32bitlimbs mul256x256_256__riscv64__64bitlimbs

mul256x256_512__riscv64: mul256x256_512__riscv64__32bitlimbs mul256x256_512__riscv64__64bitlimbs


mul256x256_256__riscv64__32bitlimbs:
	riscv64-linux-gnu-gcc -std=c99 mul256x256.c mul256x256_256_32bitlimbs.riscv64.s -o mul256x256_256_32bitlimbs.riscv64.elf -static -fno-pie -no-pie -DBENCHMARK=0 -DTO512=0
	${QEMU_RISCV64_DIR}qemu-riscv64 mul256x256_256_32bitlimbs.riscv64.elf 0xafa09157b75a333d7bcbbfd3369bab9da49cae64d5c80de042546757925b407f 0x271f2856836df87900d07d2b3ffdaa5e24f259d1c263155bf3305ad8ec88622c 0x35a92bedfcd8ed1e1a279a5f6995447ced4126ae45b6aadc8dfe3a2b6dd7b3d4

mul256x256_512__riscv64__32bitlimbs:
	riscv64-linux-gnu-gcc -std=c99 mul256x256.c mul256x256_512_32bitlimbs.riscv64.s -o mul256x256_512_32bitlimbs.riscv64.elf -static -fno-pie -no-pie -DBENCHMARK=0 -DTO512=1
	${QEMU_RISCV64_DIR}qemu-riscv64 mul256x256_512_32bitlimbs.riscv64.elf 0xab53f0ed805ffc05fe929335ebae133dda368c3f8521522c41e95c0a8e264d4d 0xc89cff12713c232a28296488b776683104e46a056c24a937c73112e6a7abaf09 0x8642a61551b10782e33e9af49d7cc77fda0d9e793be4f61e9d1c9059acb25094195463895af1c78f5db2e61ce96830be752c4152d8a441f9437d40bc0b9f5ab5


mul256x256_256__riscv64__64bitlimbs:
	riscv64-linux-gnu-gcc -std=c99 mul256x256.c mul256x256_256_64bitlimbs.riscv64.s -o mul256x256_256_64bitlimbs.riscv64.elf -static -fno-pie -no-pie -DBENCHMARK=0 -DTO512=0
	${QEMU_RISCV64_DIR}qemu-riscv64 mul256x256_256_64bitlimbs.riscv64.elf 0xafa09157b75a333d7bcbbfd3369bab9da49cae64d5c80de042546757925b407f 0x271f2856836df87900d07d2b3ffdaa5e24f259d1c263155bf3305ad8ec88622c 0x35a92bedfcd8ed1e1a279a5f6995447ced4126ae45b6aadc8dfe3a2b6dd7b3d4

mul256x256_512__riscv64__64bitlimbs:
	riscv64-linux-gnu-gcc -std=c99 mul256x256.c mul256x256_512_64bitlimbs.riscv64.s -o mul256x256_512_64bitlimbs.riscv64.elf -static -fno-pie -no-pie -DBENCHMARK=0 -DTO512=1
	${QEMU_RISCV64_DIR}qemu-riscv64 mul256x256_512_64bitlimbs.riscv64.elf 0xab53f0ed805ffc05fe929335ebae133dda368c3f8521522c41e95c0a8e264d4d 0xc89cff12713c232a28296488b776683104e46a056c24a937c73112e6a7abaf09 0x8642a61551b10782e33e9af49d7cc77fda0d9e793be4f61e9d1c9059acb25094195463895af1c78f5db2e61ce96830be752c4152d8a441f9437d40bc0b9f5ab5



# wasm32

# note: must set path to wabt

mul256x256_wasm32: mul256x256_256__wasm32 mul256x256_512__wasm32

mul256x256_256__wasm32:
	${WABT_DIR}wat2wasm mul256x256_256.wasm32.wat
	${WABT_DIR}wasm-interp mul256x256_256.wasm32.wasm --run-all-exports

mul256x256_512__wasm32:
	${WABT_DIR}wat2wasm mul256x256_512.wasm32.wat
	${WABT_DIR}wasm-interp mul256x256_512.wasm32.wasm --run-all-exports


clean:
	rm *.elf
