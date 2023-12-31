; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 2

; RUN: llc < %s -mtriple=x86_64 -mcpu=icelake-server | FileCheck %s

define <1 x i1> @f(<1 x float> %0) nounwind {
; CHECK-LABEL: f:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pushq %rax
; CHECK-NEXT:    vcmpeqss {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0, %k0
; CHECK-NEXT:    kmovd %k0, %edi
; CHECK-NEXT:    callq g@PLT
; CHECK-NEXT:    popq %rcx
; CHECK-NEXT:    retq
  %A = fcmp oeq <1 x float> %0, <float 0x36A0000000000000>
  %B = call <1 x i1> @g(<1 x i1> %A)
  ret <1 x i1> %B
}

declare <1 x i1> @g(<1 x i1> %0) nounwind
