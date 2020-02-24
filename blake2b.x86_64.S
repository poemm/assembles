
/*
as blake2b.x86_64.S -o blake2b.x86_64.o
objdump -D blake2b.x86_64.o
*/
	.globl blake2b_compress


# note: 
# changed rbp to rax
# changed rsp to r15

.macro mix va vb vc vd x y tmpreg
	add	\x, \va
	add	\vb, \va
	xor	\va, \vd
	#ror	$32, \vd
	rorx	$32, \vd, \vd

	add	\vd, \vc
	xor	\vc, \vb
	#ror	$24, \vb
	rorx	$24, \vb, \vb

	add	\y, \va
	add	\vb, \va
	xor	\va, \vd
	#ror	$16, \vd
	rorx	$16, \vd, \vd

	add	\vd, \vc
	xor	\vc, \vb
	#ror	$63, \vb
	rorx	$63, \vb, \vb
.endm

.macro call_mix mptr vptr va vb vc vd sa sb
	mov	8*\sa(\mptr),%rax
	mov	8*\sb(\mptr),%r15 
	mov	\va*8(\vptr),%r10 
	mov	\vb*8(\vptr),%r11
	mov	\vc*8(\vptr),%r12 
	mov	\vd*8(\vptr),%r13
	mix	%r10, %r11, %r12, %r13, %rax, %r15, %r14
	mov	%r10, \va*8(\vptr)
	mov	%r11, \vb*8(\vptr)
	mov	%r12, \vc*8(\vptr)
	mov	%r13, \vd*8(\vptr)
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
	mov	\i*8(\hptr), \reg0
	mov	\i*8(\vptr), \reg1
	mov	(\i+8)*8(\vptr), \reg2
	xor	\reg1, \reg0
	xor	\reg2, \reg0
	mov	\reg0, \i*8(\hptr)
.endm

.macro compress hptr chunkptr tptr isLastBlock ivptr vptr

	# set up local work vector V
	movq	0*8(\hptr), %rax
	movq	%rax, 0*8(\vptr)
	mov	1*8(\hptr), %r15
	mov	%r15, 1*8(\vptr)
	mov	2*8(\hptr), %r10
	mov	%r10, 2*8(\vptr)
	mov	3*8(\hptr), %r11
	mov	%r11, 3*8(\vptr)
	mov	4*8(\hptr), %r12
	mov	%r12, 4*8(\vptr)
	mov	5*8(\hptr), %r13
	mov	%r13, 5*8(\vptr)
	mov	6*8(\hptr), %r14
	mov	%r14, 6*8(\vptr)
	mov	7*8(\hptr), %rax
	mov	%rax, 7*8(\vptr)

	mov	0*8(\ivptr), %r15
	mov	%r15, 8*8(\vptr)
	mov	1*8(\ivptr), %r10
	mov	%r10, 9*8(\vptr)
	mov	2*8(\ivptr), %r11
	mov	%r11, 10*8(\vptr)
	mov	3*8(\ivptr), %r12
	mov	%r12, 11*8(\vptr)
	mov	4*8(\ivptr), %r13
	#mov	%r13, 12*8(\vptr)
	mov	5*8(\ivptr), %r14
	#mov	%r14, 13*8(\vptr)
	mov	6*8(\ivptr), %rax
	#mov	%rax, 14*8(\vptr)
	mov	7*8(\ivptr), %r15
	mov	%r15, 15*8(\vptr)

	# mix the 128-bit counter t into v12:v13
	mov	0*8(\tptr), %r10
	mov	1*8(\tptr), %r11
	xor	%r10, %r13
	xor	%r11, %r14
	mov	%r13, 12*8(\vptr)
	mov	%r14, 13*8(\vptr)

	# last block requries inverting all the bits in v14
	mov	$FFptr, %r10
	mov	0(%r10), %r12
	mov	%rax, %r15
	xor	%r12, %r15
	mov	%r15, 8(%r10)
	cmp	$1, \isLastBlock 	# todo: test this give problems when isLastBlock=0
	sete	%r11b
	shl	$3, %r11
	add	%r11, %r10
	mov	0(%r10), %r12
	mov	%r12, 14*8(\vptr)

	# for testing
	#mov	%r10, %rax
	#mov	$FFptr, %rax
	#mov	$FFptr, %rax
	#add	$1, %rax

	# twelve rounds of cryptographic mixing
	compress_loop \chunkptr \vptr

	# mix the upper and lower halves of V into ongoing state vector h
	mix_v_h 0 %rax %r15 %r10 \hptr \vptr
	mix_v_h 1 %r11 %r12 %r13 \hptr \vptr
	mix_v_h 2 %rax %r15 %r10 \hptr \vptr
	mix_v_h 3 %r11 %r12 %r13 \hptr \vptr
	mix_v_h 4 %rax %r15 %r10 \hptr \vptr
	mix_v_h 5 %r11 %r12 %r13 \hptr \vptr
	mix_v_h 6 %rax %r15 %r10 \hptr \vptr
	mix_v_h 7 %r11 %r12 %r13 \hptr \vptr

/*
*/

	# testing junk
	#mov	8(\hptr), %r10
	#mov	%r10, 8*8(\vptr)
	#mov	\hptr, %rdi
	#ret
/*
*/
/*
*/

.endm

	.text

blake2b_compress:
	# we don't use caller-saved registers, so no need to save them

        # following C calling conventions, save registers
/*
	push	%rbp
	#mov	%rsp, %rbp
        push	%rbx
        #push	%rax
        push	%r12
        push	%r13
        push	%r14
        push	%r15
*/

	#push	%rbp
 	#mov	%rbp, %rsp

        push    %rbx
        push    %rbp
        #push    %r8
        #push    %r9
        #push    %r10
        #push    %r11
        push    %r12
        push    %r13
        push    %r14
        push    %r15

///*
        #xorq    %rax, %rax
        xorq    %rbx, %rbx
        ##xorq    %rcx, %rcx
        #xorq    %rbp, %rbp
        ##xorq    %rsp, %rsp
        ##xorq    %r8, %r8
        ##xorq    %r9, %r9
        xorq    %r10, %r10
        xorq    %r11, %r11
        xorq    %r12, %r12
        xorq    %r13, %r13
        xorq    %r14, %r14
        xorq    %r15, %r15
//*/



        #push	%r10
        #push	%r11

	# args are pointers to %rdi=hptr, %rsi=chunkptr, %rdx=numBytesCompressedptr, %rcx=isLastBlock
	#   where hptr is uint64_t[8]
	#         chunkptr is uint8_t* and chunk is 128 bytes
	#         numBytesCompressedptr is uint64_t[2]
	#         isLastblock is uint64_t
	# also, we set %r8=ivptr, %r9=vptr
	#   where vptr is uint64_t[16], will be overwritten
	#	 ivptr is uint64_t[8] to const values
	#mov	$IV, %r8
	mov	$V, %r9
	compress %rdi %rsi %rdx %rcx %r8 %r9

	# testing
	#mov	%rdi, %rax

	# testing junk
	#mov $V, %rax

	# junk for testing
	#movq	8(%rdi), %rax
	#movq	%rax, 8(%r9)
	#movq	%rax, 8(%r8)

	# testing junk
	#mov	8(%rdi), %r10
	#mov	%r10, 8(%rsi)
	#mov	\hptr, %rdi
	#ret

        #pop	%r11
        #pop	%r10



        pop    %r15
        pop    %r14
        pop    %r13
        pop    %r12
        #pop    %r11
        #pop    %r10
        #pop    %r9
        #pop    %r8
        pop    %rbp
        pop    %rbx

 	#mov	%rsp, %rbp
 	#pop	%rbp

/*
	# as callee, return saved registers to original
	pop	%r15
	pop	%r14
	pop	%r13
	pop	%r12
	#pop	%rax
	pop	%rbx
	pop	%rbp
*/

	ret


.data

//.align 3
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
