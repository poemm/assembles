
/*
riscv64-linux-gnu-as blake2b.riscv64.S -o blake2b.riscv64.o
riscv64-linux-gnu-objdump -D blake2b.riscv64.o
*/
	.globl blake2b_compress



.macro rotr reg,imm,tmpreg
	srli	\tmpreg, \reg, \imm
	slli	\reg, \reg, 64-\imm
	or	\reg, \reg, \tmpreg
.endm

.macro mix va vb vc vd x y tmpreg
	add	\va, \va, \x
	add	\va, \va, \vb
	xor	\vd, \vd, \va
	rotr	\vd, 32, \tmpreg

	add	\vc, \vc, \vd
	xor	\vb, \vb, \vc
	rotr	\vb, 24, \tmpreg

	add	\va, \va, \y
	add	\va, \va, \vb
	xor	\vd, \vd, \va
	rotr	\vd, 16, \tmpreg

	add	\vc, \vc, \vd
	xor	\vb, \vb, \vc
	rotr	\vb, 63, \tmpreg
.endm

.macro call_mix mptr vptr va vb vc vd sa sb
	ld	t0, 8*\sa(\mptr)
	ld	t1, 8*\sb(\mptr)
	ld	t2, \va*8(\vptr)
	ld	t3, \vb*8(\vptr)
	ld	t4, \vc*8(\vptr)
	ld	t5, \vd*8(\vptr)
	mix	t2, t3, t4, t5, t0, t1, t6
	sd	t2, \va*8(\vptr)
	sd	t3, \vb*8(\vptr)
	sd	t4, \vc*8(\vptr)
	sd	t5, \vd*8(\vptr)
.endm

.macro compress_loop_iter mptr vptr s0 s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13 s14 s15
	call_mix	\mptr \vptr 0 4 8 12 \s0 \s1
	call_mix	\mptr \vptr 1 5 9 13 \s2 \s3
	call_mix	\mptr \vptr 2 6 10 14 \s4 \s5
	call_mix	\mptr \vptr 3 7 11 15 \s6 \s7
	call_mix	\mptr \vptr 0 5 10 15 \s8 \s9
	call_mix	\mptr \vptr 1 6 11 12 \s10 \s11
	call_mix	\mptr \vptr 2 7 8 13 \s12 \s13
	call_mix	\mptr \vptr 3 4 9 14 \s14 \s15
.endm

.macro compress_loop mptr vptr
	compress_loop_iter \mptr \vptr 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
	compress_loop_iter \mptr \vptr 14 10  4  8  9 15 13  6  1 12  0  2 11  7  5  3
	compress_loop_iter \mptr \vptr 11  8 12  0  5  2 15 13 10 14  3  6  7  1  9  4
	compress_loop_iter \mptr \vptr 7  9  3  1 13 12 11 14  2  6  5 10  4  0 15  8
	compress_loop_iter \mptr \vptr 9  0  5  7  2  4 10 15 14  1 11 12  6  8  3 13
	compress_loop_iter \mptr \vptr 2 12  6 10  0 11  8  3  4 13  7  5 15 14  1  9
	compress_loop_iter \mptr \vptr 12  5  1 15 14 13  4 10  0  7  6  3  9  2  8 11
	compress_loop_iter \mptr \vptr 13 11  7 14 12  1  3  9  5  0 15  4  8  6  2 10
	compress_loop_iter \mptr \vptr 6 15 14  9 11  3  0  8 12  2 13  7  1  4 10  5
	compress_loop_iter \mptr \vptr 10  2  8  4  7  6  1  5 15 11  9 14  3 12 13  0
	compress_loop_iter \mptr \vptr 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
	compress_loop_iter \mptr \vptr 14 10  4  8  9 15 13  6  1 12  0  2 11  7  5  3

.endm

.macro mix_v_h i reg0 reg1 reg2 hptr vptr
	ld	\reg0, \i*8(\hptr)
	ld	\reg1, \i*8(\vptr)
	ld	\reg2, (\i+8)*8(\vptr)
	xor	\reg0, \reg0, \reg1
	xor	\reg0, \reg0, \reg2
	sd	\reg0, \i*8(\hptr)
.endm

.macro compress hptr chunkptr tptr isLastBlock ivptr vptr


	# set up local work vector V
	ld	t0, 0*8(\hptr)
	sd	t0, 0*8(\vptr)
	ld	t1, 1*8(\hptr)
	sd	t1, 1*8(\vptr)
	ld	t2, 2*8(\hptr)
	sd	t2, 2*8(\vptr)
	ld	t3, 3*8(\hptr)
	sd	t3, 3*8(\vptr)
	ld	t4, 4*8(\hptr)
	sd	t4, 4*8(\vptr)
	ld	t5, 5*8(\hptr)
	sd	t5, 5*8(\vptr)
	ld	t6, 6*8(\hptr)
	sd	t6, 6*8(\vptr)
	ld	t0, 7*8(\hptr)
	sd	t0, 7*8(\vptr)


	ld	t1, 0*8(\ivptr)
	sd	t1, 8*8(\vptr)
	ld	t2, 1*8(\ivptr)
	sd	t2, 9*8(\vptr)
	ld	t3, 2*8(\ivptr)
	sd	t3, 10*8(\vptr)
	ld	t4, 3*8(\ivptr)
	sd	t4, 11*8(\vptr)
	ld	t5, 4*8(\ivptr)
	#sd	t5, 12*8(\vptr)
	ld	t6, 5*8(\ivptr)
	#sd	t6, 13*8(\vptr)
	ld	t0, 6*8(\ivptr)
	#sd	t0, 14*8(\vptr)
	ld	t1, 7*8(\ivptr)
	sd	t1, 15*8(\vptr)

	# mix the 128-bit counter t into v12:v13
	ld	t2, 0*8(\tptr)
	ld	t3, 1*8(\tptr)
	xor	t5, t5, t2
	xor	t6, t6, t3
	sd	t5, 12*8(\vptr)
	sd	t6, 13*8(\vptr)

	# last block requries inverting all the bits in v14
	la	t2, FFptr
	ld	t4, 0(t2)
	mv	t1, t0
	xor	t1, t1, t4
	sd	t1, 8(t2)
	snez	t3, \isLastBlock
	slli	t3, t3, 3
	add	t2, t2, t3
	ld	t4, 0(t2)
	#xor	t0, t0, t4		#oops, just need one xor, flipped seqz to snez above
	#sd	t0, 14*8(\vptr)
	sd	t4, 14*8(\vptr)


	# twelve rounds of cryptographic mixing
	compress_loop \chunkptr \vptr

	# testing
	#la	a0, V

	# mix the upper and lower halves of V into ongoing state vector h
	mix_v_h 0 t0 t1 t2 \hptr \vptr
	mix_v_h 1 t3 t4 t5 \hptr \vptr
	mix_v_h 2 t0 t1 t2 \hptr \vptr
	mix_v_h 3 t3 t4 t5 \hptr \vptr
	mix_v_h 4 t0 t1 t2 \hptr \vptr
	mix_v_h 5 t3 t4 t5 \hptr \vptr
	mix_v_h 6 t0 t1 t2 \hptr \vptr
	mix_v_h 7 t3 t4 t5 \hptr \vptr
/*
*/

	# testing junk
	#ld	t2, 8(\ivptr)
	#sd	t2, 8*8(\vptr)
	#mv	a0, \hptr
	#ret
.endm

	.text

blake2b_compress:
	# we don't use caller-saved registers, so no need to save them

/*
	mul	a0, a0, a0
	mul	a0, a0, a0
	mul	a0, a0, a0
	mul	a0, a0, a0
	mul	a0, a0, a0
	mul	a0, a0, a0
*/

	# args are pointers to a0=hptr, a1=chunkptr, a2=numBytesCompressedptr, a3=isLastBlock
	#   where hptr is uint64_t[8]
	#         chunkptr is uint8_t* and chunk is 128 bytes
	#         numBytesCompressedptr is uint64_t[2]
	#         isLastblock is uint64_t
	# also, we set a4=vptr, a5=ivptr
	#   where vptr is uint64_t[16], will be overwritten
	#	 ivptr is uint64_t[8] to const values
	#la	a4, IV
	la	a5, V
	compress a0 a1 a2 a3 a4 a5

/*
	mul	a0, a0, a0
	mul	a0, a0, a0
	mul	a0, a0, a0
	mul	a0, a0, a0
	mul	a0, a0, a0
	mul	a0, a0, a0
*/

	ret

.data

.align 3
IV:
	.quad 0x6a09e667f3bcc908
	.quad 0xbb67ae8584caa73b
	.quad 0x3c6ef372fe94f82b
	.quad 0xa54ff53a5f1d36f1
	.quad 0x510e527fade682d1
	.quad 0x9b05688c2b3e6c1f
	.quad 0x1f83d9abfb41bd6b
	.quad 0x5be0cd19137e2179
V:
	.quad 0x00
	.quad 0x00
	.quad 0x00
	.quad 0x00
	.quad 0x00
	.quad 0x00
	.quad 0x00
	.quad 0x00
	.quad 0x00
	.quad 0x00
	.quad 0x00
	.quad 0x00
	.quad 0x00
	.quad 0x00
	.quad 0x00
	.quad 0x00
FFptr:
	.quad 0xFFFFFFFFFFFFFFFF
FFptrPlus8:
	.quad 0x00
