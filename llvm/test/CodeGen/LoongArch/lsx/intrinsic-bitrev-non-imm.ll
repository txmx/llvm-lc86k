; RUN: not llc --mtriple=loongarch64 --mattr=+lsx < %s 2>&1 | FileCheck %s

declare <16 x i8> @llvm.loongarch.lsx.vbitrevi.b(<16 x i8>, i32)

define <16 x i8> @lsx_vbitrevi_b(<16 x i8> %va, i32 %b) nounwind {
; CHECK: immarg operand has non-immediate parameter
entry:
  %res = call <16 x i8> @llvm.loongarch.lsx.vbitrevi.b(<16 x i8> %va, i32 %b)
  ret <16 x i8> %res
}

declare <8 x i16> @llvm.loongarch.lsx.vbitrevi.h(<8 x i16>, i32)

define <8 x i16> @lsx_vbitrevi_h(<8 x i16> %va, i32 %b) nounwind {
; CHECK: immarg operand has non-immediate parameter
entry:
  %res = call <8 x i16> @llvm.loongarch.lsx.vbitrevi.h(<8 x i16> %va, i32 %b)
  ret <8 x i16> %res
}

declare <4 x i32> @llvm.loongarch.lsx.vbitrevi.w(<4 x i32>, i32)

define <4 x i32> @lsx_vbitrevi_w(<4 x i32> %va, i32 %b) nounwind {
; CHECK: immarg operand has non-immediate parameter
entry:
  %res = call <4 x i32> @llvm.loongarch.lsx.vbitrevi.w(<4 x i32> %va, i32 %b)
  ret <4 x i32> %res
}

declare <2 x i64> @llvm.loongarch.lsx.vbitrevi.d(<2 x i64>, i32)

define <2 x i64> @lsx_vbitrevi_d(<2 x i64> %va, i32 %b) nounwind {
; CHECK: immarg operand has non-immediate parameter
entry:
  %res = call <2 x i64> @llvm.loongarch.lsx.vbitrevi.d(<2 x i64> %va, i32 %b)
  ret <2 x i64> %res
}
