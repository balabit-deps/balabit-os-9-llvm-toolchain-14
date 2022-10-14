; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv64 -mattr=+zkne -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV64ZKNE

declare i64 @llvm.riscv.aes64es(i64, i64);

define i64 @aes64es(i64 %a, i64 %b) nounwind {
; RV64ZKNE-LABEL: aes64es
; RV64ZKNE: # %bb.0:
; RV64ZKNE-NEXT: aes64es a0, a0, a1
; RV64ZKNE-NEXT: ret
    %val = call i64 @llvm.riscv.aes64es(i64 %a, i64 %b)
    ret i64 %val
}

declare i64 @llvm.riscv.aes64esm(i64, i64);

define i64 @aes64esm(i64 %a, i64 %b) nounwind {
; RV64ZKNE-LABEL: aes64esm
; RV64ZKNE: # %bb.0:
; RV64ZKNE-NEXT: aes64esm a0, a0, a1
; RV64ZKNE-NEXT: ret
    %val = call i64 @llvm.riscv.aes64esm(i64 %a, i64 %b)
    ret i64 %val
}