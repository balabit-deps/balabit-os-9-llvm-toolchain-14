; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-- -mattr=+sse2 | FileCheck %s --check-prefixes=SSE
; RUN: llc < %s -mtriple=x86_64-- -mattr=+avx  | FileCheck %s --check-prefixes=AVX,AVX1
; RUN: llc < %s -mtriple=x86_64-- -mattr=+avx2 | FileCheck %s --check-prefixes=AVX,AVX2
; RUN: llc < %s -mtriple=x86_64-- -mattr=+avx2,+fast-variable-crosslane-shuffle,+fast-variable-perlane-shuffle | FileCheck %s --check-prefixes=AVX,AVX2
; RUN: llc < %s -mtriple=x86_64-- -mattr=+avx2,+fast-variable-perlane-shuffle | FileCheck %s --check-prefixes=AVX,AVX2
; RUN: llc < %s -mtriple=x86_64-- -mattr=+avx512bw,+avx512vl | FileCheck %s --check-prefixes=AVX512

; These patterns are produced by LoopVectorizer for interleaved loads.

define void @load_i8_stride2_vf2(<4 x i8>* %in.vec, <2 x i8>* %out.vec0, <2 x i8>* %out.vec1) nounwind {
; SSE-LABEL: load_i8_stride2_vf2:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqa (%rdi), %xmm0
; SSE-NEXT:    movdqa {{.*#+}} xmm1 = [255,255,255,255,255,255,255,255]
; SSE-NEXT:    pand %xmm0, %xmm1
; SSE-NEXT:    packuswb %xmm1, %xmm1
; SSE-NEXT:    psrlw $8, %xmm0
; SSE-NEXT:    packuswb %xmm0, %xmm0
; SSE-NEXT:    movd %xmm1, %eax
; SSE-NEXT:    movw %ax, (%rsi)
; SSE-NEXT:    movd %xmm0, %eax
; SSE-NEXT:    movw %ax, (%rdx)
; SSE-NEXT:    retq
;
; AVX-LABEL: load_i8_stride2_vf2:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovdqa (%rdi), %xmm0
; AVX-NEXT:    vpshufb {{.*#+}} xmm1 = xmm0[0,2,u,u,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[1,3,u,u,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX-NEXT:    vpextrw $0, %xmm1, (%rsi)
; AVX-NEXT:    vpextrw $0, %xmm0, (%rdx)
; AVX-NEXT:    retq
;
; AVX512-LABEL: load_i8_stride2_vf2:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512-NEXT:    vpmovwb %xmm0, %xmm1
; AVX512-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[1,3,u,u,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX512-NEXT:    vpextrw $0, %xmm1, (%rsi)
; AVX512-NEXT:    vpextrw $0, %xmm0, (%rdx)
; AVX512-NEXT:    retq
  %wide.vec = load <4 x i8>, <4 x i8>* %in.vec, align 32

  %strided.vec0 = shufflevector <4 x i8> %wide.vec, <4 x i8> poison, <2 x i32> <i32 0, i32 2>
  %strided.vec1 = shufflevector <4 x i8> %wide.vec, <4 x i8> poison, <2 x i32> <i32 1, i32 3>

  store <2 x i8> %strided.vec0, <2 x i8>* %out.vec0, align 32
  store <2 x i8> %strided.vec1, <2 x i8>* %out.vec1, align 32

  ret void
}

define void @load_i8_stride2_vf4(<8 x i8>* %in.vec, <4 x i8>* %out.vec0, <4 x i8>* %out.vec1) nounwind {
; SSE-LABEL: load_i8_stride2_vf4:
; SSE:       # %bb.0:
; SSE-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; SSE-NEXT:    movdqa {{.*#+}} xmm1 = [255,255,255,255,255,255,255,255]
; SSE-NEXT:    pand %xmm0, %xmm1
; SSE-NEXT:    packuswb %xmm1, %xmm1
; SSE-NEXT:    psrlw $8, %xmm0
; SSE-NEXT:    packuswb %xmm0, %xmm0
; SSE-NEXT:    movd %xmm1, (%rsi)
; SSE-NEXT:    movd %xmm0, (%rdx)
; SSE-NEXT:    retq
;
; AVX-LABEL: load_i8_stride2_vf4:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovq {{.*#+}} xmm0 = mem[0],zero
; AVX-NEXT:    vpshufb {{.*#+}} xmm1 = xmm0[0,2,4,6,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[1,3,5,7,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX-NEXT:    vmovd %xmm1, (%rsi)
; AVX-NEXT:    vmovd %xmm0, (%rdx)
; AVX-NEXT:    retq
;
; AVX512-LABEL: load_i8_stride2_vf4:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovq {{.*#+}} xmm0 = mem[0],zero
; AVX512-NEXT:    vpmovwb %xmm0, %xmm1
; AVX512-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[1,3,5,7,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX512-NEXT:    vmovd %xmm1, (%rsi)
; AVX512-NEXT:    vmovd %xmm0, (%rdx)
; AVX512-NEXT:    retq
  %wide.vec = load <8 x i8>, <8 x i8>* %in.vec, align 32

  %strided.vec0 = shufflevector <8 x i8> %wide.vec, <8 x i8> poison, <4 x i32> <i32 0, i32 2, i32 4, i32 6>
  %strided.vec1 = shufflevector <8 x i8> %wide.vec, <8 x i8> poison, <4 x i32> <i32 1, i32 3, i32 5, i32 7>

  store <4 x i8> %strided.vec0, <4 x i8>* %out.vec0, align 32
  store <4 x i8> %strided.vec1, <4 x i8>* %out.vec1, align 32

  ret void
}

define void @load_i8_stride2_vf8(<16 x i8>* %in.vec, <8 x i8>* %out.vec0, <8 x i8>* %out.vec1) nounwind {
; SSE-LABEL: load_i8_stride2_vf8:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqa (%rdi), %xmm0
; SSE-NEXT:    movdqa {{.*#+}} xmm1 = [255,255,255,255,255,255,255,255]
; SSE-NEXT:    pand %xmm0, %xmm1
; SSE-NEXT:    packuswb %xmm1, %xmm1
; SSE-NEXT:    psrlw $8, %xmm0
; SSE-NEXT:    packuswb %xmm0, %xmm0
; SSE-NEXT:    movq %xmm1, (%rsi)
; SSE-NEXT:    movq %xmm0, (%rdx)
; SSE-NEXT:    retq
;
; AVX-LABEL: load_i8_stride2_vf8:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovdqa (%rdi), %xmm0
; AVX-NEXT:    vpshufb {{.*#+}} xmm1 = xmm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[1,3,5,7,9,11,13,15,u,u,u,u,u,u,u,u]
; AVX-NEXT:    vmovq %xmm1, (%rsi)
; AVX-NEXT:    vmovq %xmm0, (%rdx)
; AVX-NEXT:    retq
;
; AVX512-LABEL: load_i8_stride2_vf8:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovdqa (%rdi), %xmm0
; AVX512-NEXT:    vpshufb {{.*#+}} xmm1 = xmm0[1,3,5,7,9,11,13,15,u,u,u,u,u,u,u,u]
; AVX512-NEXT:    vpmovwb %xmm0, (%rsi)
; AVX512-NEXT:    vmovq %xmm1, (%rdx)
; AVX512-NEXT:    retq
  %wide.vec = load <16 x i8>, <16 x i8>* %in.vec, align 32

  %strided.vec0 = shufflevector <16 x i8> %wide.vec, <16 x i8> poison, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %strided.vec1 = shufflevector <16 x i8> %wide.vec, <16 x i8> poison, <8 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15>

  store <8 x i8> %strided.vec0, <8 x i8>* %out.vec0, align 32
  store <8 x i8> %strided.vec1, <8 x i8>* %out.vec1, align 32

  ret void
}

define void @load_i8_stride2_vf16(<32 x i8>* %in.vec, <16 x i8>* %out.vec0, <16 x i8>* %out.vec1) nounwind {
; SSE-LABEL: load_i8_stride2_vf16:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqa (%rdi), %xmm0
; SSE-NEXT:    movdqa 16(%rdi), %xmm1
; SSE-NEXT:    movdqa {{.*#+}} xmm2 = [255,255,255,255,255,255,255,255]
; SSE-NEXT:    movdqa %xmm1, %xmm3
; SSE-NEXT:    pand %xmm2, %xmm3
; SSE-NEXT:    pand %xmm0, %xmm2
; SSE-NEXT:    packuswb %xmm3, %xmm2
; SSE-NEXT:    psrlw $8, %xmm1
; SSE-NEXT:    psrlw $8, %xmm0
; SSE-NEXT:    packuswb %xmm1, %xmm0
; SSE-NEXT:    movdqa %xmm2, (%rsi)
; SSE-NEXT:    movdqa %xmm0, (%rdx)
; SSE-NEXT:    retq
;
; AVX-LABEL: load_i8_stride2_vf16:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovdqa {{.*#+}} xmm0 = [255,255,255,255,255,255,255,255]
; AVX-NEXT:    vmovdqa (%rdi), %xmm1
; AVX-NEXT:    vmovdqa 16(%rdi), %xmm2
; AVX-NEXT:    vpand %xmm0, %xmm2, %xmm3
; AVX-NEXT:    vpand %xmm0, %xmm1, %xmm0
; AVX-NEXT:    vpackuswb %xmm3, %xmm0, %xmm0
; AVX-NEXT:    vmovdqa {{.*#+}} xmm3 = <1,3,5,7,9,11,13,15,u,u,u,u,u,u,u,u>
; AVX-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX-NEXT:    vpshufb %xmm3, %xmm1, %xmm1
; AVX-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; AVX-NEXT:    vmovdqa %xmm0, (%rsi)
; AVX-NEXT:    vmovdqa %xmm1, (%rdx)
; AVX-NEXT:    retq
;
; AVX512-LABEL: load_i8_stride2_vf16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovdqa (%rdi), %ymm0
; AVX512-NEXT:    vmovdqa (%rdi), %xmm1
; AVX512-NEXT:    vmovdqa 16(%rdi), %xmm2
; AVX512-NEXT:    vmovdqa {{.*#+}} xmm3 = <1,3,5,7,9,11,13,15,u,u,u,u,u,u,u,u>
; AVX512-NEXT:    vpshufb %xmm3, %xmm2, %xmm2
; AVX512-NEXT:    vpshufb %xmm3, %xmm1, %xmm1
; AVX512-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; AVX512-NEXT:    vpmovwb %ymm0, (%rsi)
; AVX512-NEXT:    vmovdqa %xmm1, (%rdx)
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %wide.vec = load <32 x i8>, <32 x i8>* %in.vec, align 32

  %strided.vec0 = shufflevector <32 x i8> %wide.vec, <32 x i8> poison, <16 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14, i32 16, i32 18, i32 20, i32 22, i32 24, i32 26, i32 28, i32 30>
  %strided.vec1 = shufflevector <32 x i8> %wide.vec, <32 x i8> poison, <16 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15, i32 17, i32 19, i32 21, i32 23, i32 25, i32 27, i32 29, i32 31>

  store <16 x i8> %strided.vec0, <16 x i8>* %out.vec0, align 32
  store <16 x i8> %strided.vec1, <16 x i8>* %out.vec1, align 32

  ret void
}

define void @load_i8_stride2_vf32(<64 x i8>* %in.vec, <32 x i8>* %out.vec0, <32 x i8>* %out.vec1) nounwind {
; SSE-LABEL: load_i8_stride2_vf32:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqa (%rdi), %xmm0
; SSE-NEXT:    movdqa 16(%rdi), %xmm1
; SSE-NEXT:    movdqa 32(%rdi), %xmm2
; SSE-NEXT:    movdqa 48(%rdi), %xmm3
; SSE-NEXT:    movdqa {{.*#+}} xmm4 = [255,255,255,255,255,255,255,255]
; SSE-NEXT:    movdqa %xmm3, %xmm5
; SSE-NEXT:    pand %xmm4, %xmm5
; SSE-NEXT:    movdqa %xmm2, %xmm6
; SSE-NEXT:    pand %xmm4, %xmm6
; SSE-NEXT:    packuswb %xmm5, %xmm6
; SSE-NEXT:    movdqa %xmm1, %xmm5
; SSE-NEXT:    pand %xmm4, %xmm5
; SSE-NEXT:    pand %xmm0, %xmm4
; SSE-NEXT:    packuswb %xmm5, %xmm4
; SSE-NEXT:    psrlw $8, %xmm3
; SSE-NEXT:    psrlw $8, %xmm2
; SSE-NEXT:    packuswb %xmm3, %xmm2
; SSE-NEXT:    psrlw $8, %xmm1
; SSE-NEXT:    psrlw $8, %xmm0
; SSE-NEXT:    packuswb %xmm1, %xmm0
; SSE-NEXT:    movdqa %xmm4, (%rsi)
; SSE-NEXT:    movdqa %xmm6, 16(%rsi)
; SSE-NEXT:    movdqa %xmm0, (%rdx)
; SSE-NEXT:    movdqa %xmm2, 16(%rdx)
; SSE-NEXT:    retq
;
; AVX1-LABEL: load_i8_stride2_vf32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm0 = [255,255,255,255,255,255,255,255]
; AVX1-NEXT:    vmovdqa (%rdi), %xmm1
; AVX1-NEXT:    vmovdqa 16(%rdi), %xmm2
; AVX1-NEXT:    vmovdqa 32(%rdi), %xmm3
; AVX1-NEXT:    vmovdqa 48(%rdi), %xmm4
; AVX1-NEXT:    vpand %xmm0, %xmm4, %xmm5
; AVX1-NEXT:    vpand %xmm0, %xmm3, %xmm6
; AVX1-NEXT:    vpackuswb %xmm5, %xmm6, %xmm5
; AVX1-NEXT:    vpand %xmm0, %xmm2, %xmm6
; AVX1-NEXT:    vpand %xmm0, %xmm1, %xmm0
; AVX1-NEXT:    vpackuswb %xmm6, %xmm0, %xmm0
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm6 = <1,3,5,7,9,11,13,15,u,u,u,u,u,u,u,u>
; AVX1-NEXT:    vpshufb %xmm6, %xmm4, %xmm4
; AVX1-NEXT:    vpshufb %xmm6, %xmm3, %xmm3
; AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm3 = xmm3[0],xmm4[0]
; AVX1-NEXT:    vpshufb %xmm6, %xmm2, %xmm2
; AVX1-NEXT:    vpshufb %xmm6, %xmm1, %xmm1
; AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm1, %ymm1
; AVX1-NEXT:    vmovdqa %xmm0, (%rsi)
; AVX1-NEXT:    vmovdqa %xmm5, 16(%rsi)
; AVX1-NEXT:    vmovaps %ymm1, (%rdx)
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: load_i8_stride2_vf32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovdqa (%rdi), %ymm0
; AVX2-NEXT:    vmovdqa 32(%rdi), %ymm1
; AVX2-NEXT:    vpshufb {{.*#+}} ymm2 = ymm1[u,u,u,u,u,u,u,u,0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u,16,18,20,22,24,26,28,30]
; AVX2-NEXT:    vpshufb {{.*#+}} ymm3 = ymm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u,16,18,20,22,24,26,28,30,u,u,u,u,u,u,u,u]
; AVX2-NEXT:    vpblendd {{.*#+}} ymm2 = ymm3[0,1],ymm2[2,3],ymm3[4,5],ymm2[6,7]
; AVX2-NEXT:    vpermq {{.*#+}} ymm2 = ymm2[0,2,1,3]
; AVX2-NEXT:    vpshufb {{.*#+}} ymm1 = ymm1[u,u,u,u,u,u,u,u,1,3,5,7,9,11,13,15,u,u,u,u,u,u,u,u,17,19,21,23,25,27,29,31]
; AVX2-NEXT:    vpshufb {{.*#+}} ymm0 = ymm0[1,3,5,7,9,11,13,15,u,u,u,u,u,u,u,u,17,19,21,23,25,27,29,31,u,u,u,u,u,u,u,u]
; AVX2-NEXT:    vpblendd {{.*#+}} ymm0 = ymm0[0,1],ymm1[2,3],ymm0[4,5],ymm1[6,7]
; AVX2-NEXT:    vpermq {{.*#+}} ymm0 = ymm0[0,2,1,3]
; AVX2-NEXT:    vmovdqa %ymm2, (%rsi)
; AVX2-NEXT:    vmovdqa %ymm0, (%rdx)
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: load_i8_stride2_vf32:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovdqu64 (%rdi), %zmm0
; AVX512-NEXT:    vmovdqa (%rdi), %ymm1
; AVX512-NEXT:    vmovdqa 32(%rdi), %ymm2
; AVX512-NEXT:    vpshufb {{.*#+}} ymm2 = ymm2[u,u,u,u,u,u,u,u,1,3,5,7,9,11,13,15,u,u,u,u,u,u,u,u,17,19,21,23,25,27,29,31]
; AVX512-NEXT:    vpshufb {{.*#+}} ymm1 = ymm1[1,3,5,7,9,11,13,15,u,u,u,u,u,u,u,u,17,19,21,23,25,27,29,31,u,u,u,u,u,u,u,u]
; AVX512-NEXT:    vpblendd {{.*#+}} ymm1 = ymm1[0,1],ymm2[2,3],ymm1[4,5],ymm2[6,7]
; AVX512-NEXT:    vpermq {{.*#+}} ymm1 = ymm1[0,2,1,3]
; AVX512-NEXT:    vpmovwb %zmm0, (%rsi)
; AVX512-NEXT:    vmovdqa %ymm1, (%rdx)
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %wide.vec = load <64 x i8>, <64 x i8>* %in.vec, align 32

  %strided.vec0 = shufflevector <64 x i8> %wide.vec, <64 x i8> poison, <32 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14, i32 16, i32 18, i32 20, i32 22, i32 24, i32 26, i32 28, i32 30, i32 32, i32 34, i32 36, i32 38, i32 40, i32 42, i32 44, i32 46, i32 48, i32 50, i32 52, i32 54, i32 56, i32 58, i32 60, i32 62>
  %strided.vec1 = shufflevector <64 x i8> %wide.vec, <64 x i8> poison, <32 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15, i32 17, i32 19, i32 21, i32 23, i32 25, i32 27, i32 29, i32 31, i32 33, i32 35, i32 37, i32 39, i32 41, i32 43, i32 45, i32 47, i32 49, i32 51, i32 53, i32 55, i32 57, i32 59, i32 61, i32 63>

  store <32 x i8> %strided.vec0, <32 x i8>* %out.vec0, align 32
  store <32 x i8> %strided.vec1, <32 x i8>* %out.vec1, align 32

  ret void
}