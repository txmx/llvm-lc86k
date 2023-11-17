; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes=slp-vectorizer -slp-threshold=-999 -mtriple=x86_64-unknown-linux-gnu -mcpu=skylake -S < %s | FileCheck %s

; The test checks that loads should not be moved below a stackrestore boundary.
define void @stackrestore1(ptr %out) {
; CHECK-LABEL: @stackrestore1(
; CHECK-NEXT:    [[STACK:%.*]] = call ptr @llvm.stacksave.p0()
; CHECK-NEXT:    [[LOCAL_ALLOCA:%.*]] = alloca [16 x i8], align 4
; CHECK-NEXT:    store <4 x float> <float 0x3FF3333340000000, float 0x3FF3333340000000, float 0x3FF3333340000000, float 0x3FF3333340000000>, ptr [[LOCAL_ALLOCA]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = load <4 x float>, ptr [[LOCAL_ALLOCA]], align 4
; CHECK-NEXT:    call void @llvm.stackrestore.p0(ptr [[STACK]])
; CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <4 x float> [[TMP1]], <4 x float> poison, <4 x i32> <i32 2, i32 3, i32 0, i32 1>
; CHECK-NEXT:    store <4 x float> [[TMP2]], ptr [[OUT:%.*]], align 4
; CHECK-NEXT:    ret void
;
  %stack = call ptr @llvm.stacksave()
  %local_alloca = alloca [16 x i8], align 4
  store float 0x3FF3333340000000, ptr %local_alloca, align 4
  %addr1 = getelementptr inbounds i8, ptr %local_alloca, i64 4
  store float 0x3FF3333340000000, ptr %addr1, align 4
  %addr2 = getelementptr inbounds i8, ptr %local_alloca, i64 8
  store float 0x3FF3333340000000, ptr %addr2, align 4
  %addr3 = getelementptr inbounds i8, ptr %local_alloca, i64 12
  store float 0x3FF3333340000000, ptr %addr3, align 4
  %val0 = load float, ptr %local_alloca, align 4
  %val1 = load float, ptr %addr1, align 4
  %val2 = load float, ptr %addr2, align 4
  %val3 = load float, ptr %addr3, align 4
  call void @llvm.stackrestore(i8* %stack)
  %outaddr2 = getelementptr inbounds float, ptr %out, i64 2
  store float %val0, ptr %outaddr2, align 4
  %outaddr3 = getelementptr inbounds float, ptr %out, i64 3
  store float %val1, ptr %outaddr3, align 4
  store float %val2, ptr %out
  %outaddr1 = getelementptr inbounds float, ptr %out, i64 1
  store float %val3, ptr %outaddr1, align 4
  ret void
}

declare i8* @llvm.stacksave()
declare void @llvm.stackrestore(i8*)