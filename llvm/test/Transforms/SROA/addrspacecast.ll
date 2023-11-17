; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes='sroa<preserve-cfg>' -S | FileCheck %s --check-prefixes=CHECK,CHECK-PRESERVE-CFG
; RUN: opt < %s -passes='sroa<modify-cfg>' -S | FileCheck %s --check-prefixes=CHECK,CHECK-MODIFY-CFG

target datalayout = "e-p:64:64:64-p1:16:16:16-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-n8:16:32:64"

declare void @llvm.memcpy.p0.p1.i32(ptr nocapture writeonly, ptr addrspace(1) nocapture readonly, i32, i1 immarg) #0
declare void @llvm.memcpy.p1.p0.i32(ptr addrspace(1) nocapture writeonly, ptr nocapture readonly, i32, i1 immarg) #0

define i64 @alloca_addrspacecast_bitcast(i64 %X) {
; CHECK-LABEL: @alloca_addrspacecast_bitcast(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    ret i64 [[X:%.*]]
;
entry:
  %A = alloca [8 x i8]
  %A.cast = addrspacecast ptr %A to ptr addrspace(1)
  store i64 %X, ptr addrspace(1) %A.cast
  %Z = load i64, ptr addrspace(1) %A.cast
  ret i64 %Z
}

define i64 @alloca_bitcast_addrspacecast(i64 %X) {
; CHECK-LABEL: @alloca_bitcast_addrspacecast(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    ret i64 [[X:%.*]]
;
entry:
  %A = alloca [8 x i8]
  %B = addrspacecast ptr %A to ptr addrspace(1)
  store i64 %X, ptr addrspace(1) %B
  %Z = load i64, ptr addrspace(1) %B
  ret i64 %Z
}

define i64 @alloca_addrspacecast_gep(i64 %X) {
; CHECK-LABEL: @alloca_addrspacecast_gep(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    ret i64 [[X:%.*]]
;
entry:
  %A.as0 = alloca [256 x i8], align 4

  %gepA.as0 = getelementptr [256 x i8], ptr %A.as0, i16 0, i16 32
  store i64 %X, ptr %gepA.as0, align 4

  %A.as1 = addrspacecast ptr %A.as0 to ptr addrspace(1)
  %gepA.as1 = getelementptr [256 x i8], ptr addrspace(1) %A.as1, i16 0, i16 32
  %Z = load i64, ptr addrspace(1) %gepA.as1, align 4

  ret i64 %Z
}

define i64 @alloca_gep_addrspacecast(i64 %X) {
; CHECK-LABEL: @alloca_gep_addrspacecast(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    ret i64 [[X:%.*]]
;
entry:
  %A.as0 = alloca [256 x i8], align 4

  %gepA.as0 = getelementptr [256 x i8], ptr %A.as0, i16 0, i16 32
  store i64 %X, ptr %gepA.as0, align 4

  %gepA.as1.bc = addrspacecast ptr %gepA.as0 to ptr addrspace(1)
  %Z = load i64, ptr addrspace(1) %gepA.as1.bc, align 4
  ret i64 %Z
}

define i64 @alloca_gep_addrspacecast_gep(i64 %X) {
; CHECK-LABEL: @alloca_gep_addrspacecast_gep(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    ret i64 [[X:%.*]]
;
entry:
  %A.as0 = alloca [256 x i8], align 4

  %gepA.as0 = getelementptr [256 x i8], ptr %A.as0, i16 0, i16 32
  store i64 %X, ptr %gepA.as0, align 4


  %gepB.as0 = getelementptr [256 x i8], ptr %A.as0, i16 0, i16 16
  %gepB.as1 = addrspacecast ptr %gepB.as0 to ptr addrspace(1)
  %gepC.as1 = getelementptr i8, ptr addrspace(1) %gepB.as1, i16 16
  %Z = load i64, ptr addrspace(1) %gepC.as1, align 4

  ret i64 %Z
}

define i64 @getAdjustedPtr_addrspacecast_gep(ptr %x) {
; CHECK-LABEL: @getAdjustedPtr_addrspacecast_gep(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CAST1:%.*]] = addrspacecast ptr [[X:%.*]] to ptr addrspace(1)
; CHECK-NEXT:    [[A_SROA_0_0_COPYLOAD:%.*]] = load i64, ptr addrspace(1) [[CAST1]], align 1
; CHECK-NEXT:    [[A_SROA_2_0_CAST1_SROA_IDX:%.*]] = getelementptr inbounds i8, ptr addrspace(1) [[CAST1]], i16 8
; CHECK-NEXT:    [[A_SROA_2_0_COPYLOAD:%.*]] = load i64, ptr addrspace(1) [[A_SROA_2_0_CAST1_SROA_IDX]], align 1
; CHECK-NEXT:    ret i64 [[A_SROA_0_0_COPYLOAD]]
;
entry:
  %a = alloca [32 x i8], align 8
  %cast1 = addrspacecast ptr %x to ptr addrspace(1)
  call void @llvm.memcpy.p0.p1.i32(ptr %a, ptr addrspace(1) %cast1, i32 16, i1 false)
  %val = load i64, ptr %a
  ret i64 %val
}

define i64 @getAdjustedPtr_gep_addrspacecast(ptr %x) {
; CHECK-LABEL: @getAdjustedPtr_gep_addrspacecast(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[GEP_X:%.*]] = getelementptr [32 x i8], ptr [[X:%.*]], i32 0, i32 16
; CHECK-NEXT:    [[CAST1:%.*]] = addrspacecast ptr [[GEP_X]] to ptr addrspace(1)
; CHECK-NEXT:    [[A_SROA_0_0_COPYLOAD:%.*]] = load i64, ptr addrspace(1) [[CAST1]], align 1
; CHECK-NEXT:    [[A_SROA_2_0_CAST1_SROA_IDX:%.*]] = getelementptr inbounds i8, ptr addrspace(1) [[CAST1]], i16 8
; CHECK-NEXT:    [[A_SROA_2_0_COPYLOAD:%.*]] = load i64, ptr addrspace(1) [[A_SROA_2_0_CAST1_SROA_IDX]], align 1
; CHECK-NEXT:    ret i64 [[A_SROA_0_0_COPYLOAD]]
;
entry:
  %a = alloca [32 x i8], align 8
  %gep.x = getelementptr [32 x i8], ptr %x, i32 0, i32 16
  %cast1 = addrspacecast ptr %gep.x to ptr addrspace(1)

  call void @llvm.memcpy.p0.p1.i32(ptr %a, ptr addrspace(1) %cast1, i32 16, i1 false)
  %val = load i64, ptr %a
  ret i64 %val
}

define i64 @getAdjustedPtr_gep_addrspacecast_gep(ptr %x) {
; CHECK-LABEL: @getAdjustedPtr_gep_addrspacecast_gep(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[GEP0_X:%.*]] = getelementptr [32 x i8], ptr [[X:%.*]], i32 0, i32 8
; CHECK-NEXT:    [[CAST1:%.*]] = addrspacecast ptr [[GEP0_X]] to ptr addrspace(1)
; CHECK-NEXT:    [[GEP1_X:%.*]] = getelementptr i8, ptr addrspace(1) [[CAST1]], i32 8
; CHECK-NEXT:    [[A_SROA_0_0_COPYLOAD:%.*]] = load i64, ptr addrspace(1) [[GEP1_X]], align 1
; CHECK-NEXT:    [[A_SROA_2_0_GEP1_X_SROA_IDX:%.*]] = getelementptr inbounds i8, ptr addrspace(1) [[GEP1_X]], i16 8
; CHECK-NEXT:    [[A_SROA_2_0_COPYLOAD:%.*]] = load i64, ptr addrspace(1) [[A_SROA_2_0_GEP1_X_SROA_IDX]], align 1
; CHECK-NEXT:    ret i64 [[A_SROA_0_0_COPYLOAD]]
;
entry:
  %a = alloca [32 x i8], align 8
  %gep0.x = getelementptr [32 x i8], ptr %x, i32 0, i32 8
  %cast1 = addrspacecast ptr %gep0.x to ptr addrspace(1)
  %gep1.x = getelementptr i8, ptr addrspace(1) %cast1, i32 8

  call void @llvm.memcpy.p0.p1.i32(ptr %a, ptr addrspace(1) %gep1.x, i32 16, i1 false)
  %val = load i64, ptr %a
  ret i64 %val
}

; Don't change the address space of a volatile operation
define i64 @alloca_addrspacecast_bitcast_volatile_store(i64 %X) {
; CHECK-LABEL: @alloca_addrspacecast_bitcast_volatile_store(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A_SROA_0:%.*]] = alloca i64, align 8
; CHECK-NEXT:    [[TMP0:%.*]] = addrspacecast ptr [[A_SROA_0]] to ptr addrspace(1)
; CHECK-NEXT:    store volatile i64 [[X:%.*]], ptr addrspace(1) [[TMP0]], align 8
; CHECK-NEXT:    [[A_SROA_0_0_A_SROA_0_0_Z:%.*]] = load i64, ptr [[A_SROA_0]], align 8
; CHECK-NEXT:    ret i64 [[A_SROA_0_0_A_SROA_0_0_Z]]
;
entry:
  %A = alloca [8 x i8]
  %A.cast = addrspacecast ptr %A to ptr addrspace(1)
  store volatile i64 %X, ptr addrspace(1) %A.cast
  %Z = load i64, ptr addrspace(1) %A.cast
  ret i64 %Z
}

%struct = type { [256 x i8], i32 }

define i65 @volatile_store_addrspacecast_slice(i65 %X, i16 %idx) {
; CHECK-LABEL: @volatile_store_addrspacecast_slice(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A_SROA_0:%.*]] = alloca [9 x i8], align 4
; CHECK-NEXT:    [[A_SROA_1:%.*]] = alloca [9 x i8], align 8
; CHECK-NEXT:    [[A_SROA_1_0_GEPB_SROA_CAST:%.*]] = addrspacecast ptr [[A_SROA_1]] to ptr addrspace(1)
; CHECK-NEXT:    store volatile i65 [[X:%.*]], ptr addrspace(1) [[A_SROA_1_0_GEPB_SROA_CAST]], align 8
; CHECK-NEXT:    br label [[L2:%.*]]
; CHECK:       L2:
; CHECK-NEXT:    [[A_SROA_0_0_A_SROA_0_20_Z:%.*]] = load i65, ptr [[A_SROA_0]], align 4
; CHECK-NEXT:    ret i65 [[A_SROA_0_0_A_SROA_0_20_Z]]
;
entry:
  %A = alloca %struct
  %B = addrspacecast ptr %A to ptr addrspace(1)
  %gepA = getelementptr %struct, ptr %A, i32 0, i32 0, i16 20
  %gepB = getelementptr i65, ptr addrspace(1) %B, i16 6
  store volatile i65 %X, ptr addrspace(1) %gepB, align 1
  br label %L2

L2:
  %Z = load i65, ptr %gepA, align 1
  ret i65 %Z
}

; Don't change the address space of a volatile operation
define i64 @alloca_addrspacecast_bitcast_volatile_load(i64 %X) {
; CHECK-LABEL: @alloca_addrspacecast_bitcast_volatile_load(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A_SROA_0:%.*]] = alloca i64, align 8
; CHECK-NEXT:    store i64 [[X:%.*]], ptr [[A_SROA_0]], align 8
; CHECK-NEXT:    [[TMP0:%.*]] = addrspacecast ptr [[A_SROA_0]] to ptr addrspace(1)
; CHECK-NEXT:    [[A_SROA_0_0_A_SROA_0_0_Z:%.*]] = load volatile i64, ptr addrspace(1) [[TMP0]], align 8
; CHECK-NEXT:    ret i64 [[A_SROA_0_0_A_SROA_0_0_Z]]
;
entry:
  %A = alloca [8 x i8]
  %A.cast = addrspacecast ptr %A to ptr addrspace(1)
  store i64 %X, ptr addrspace(1) %A.cast
  %Z = load volatile i64, ptr addrspace(1) %A.cast
  ret i64 %Z
}

declare void @llvm.memset.p1.i32(ptr addrspace(1) nocapture, i8, i32, i1) nounwind

define i65 @volatile_load_addrspacecast_slice(i65 %X, i16 %idx) {
; CHECK-LABEL: @volatile_load_addrspacecast_slice(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A_SROA_0:%.*]] = alloca [9 x i8], align 4
; CHECK-NEXT:    [[A_SROA_1:%.*]] = alloca [9 x i8], align 8
; CHECK-NEXT:    [[A_SROA_1_0_GEPB_SROA_CAST:%.*]] = addrspacecast ptr [[A_SROA_1]] to ptr addrspace(1)
; CHECK-NEXT:    store i65 [[X:%.*]], ptr addrspace(1) [[A_SROA_1_0_GEPB_SROA_CAST]], align 8
; CHECK-NEXT:    br label [[L2:%.*]]
; CHECK:       L2:
; CHECK-NEXT:    [[A_SROA_0_0_A_SROA_0_20_Z:%.*]] = load volatile i65, ptr [[A_SROA_0]], align 4
; CHECK-NEXT:    ret i65 [[A_SROA_0_0_A_SROA_0_20_Z]]
;
entry:
  %A = alloca %struct
  %B = addrspacecast ptr %A to ptr addrspace(1)
  %gepA = getelementptr %struct, ptr %A, i32 0, i32 0, i16 20
  %gepB = getelementptr i65, ptr addrspace(1) %B, i16 6
  store i65 %X, ptr addrspace(1) %gepB, align 1
  br label %L2

L2:
  %Z = load volatile i65, ptr %gepA, align 1
  ret i65 %Z
}

; Don't change the address space of a volatile operation
define i32 @volatile_memset() {
; CHECK-LABEL: @volatile_memset(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A_SROA_0:%.*]] = alloca i32, align 4
; CHECK-NEXT:    [[TMP0:%.*]] = addrspacecast ptr [[A_SROA_0]] to ptr addrspace(1)
; CHECK-NEXT:    store volatile i32 707406378, ptr addrspace(1) [[TMP0]], align 4
; CHECK-NEXT:    [[A_SROA_0_0_A_SROA_0_0_VAL:%.*]] = load i32, ptr [[A_SROA_0]], align 4
; CHECK-NEXT:    ret i32 [[A_SROA_0_0_A_SROA_0_0_VAL]]
;
entry:
  %a = alloca [4 x i8]
  %asc = addrspacecast ptr %a to ptr addrspace(1)
  call void @llvm.memset.p1.i32(ptr addrspace(1) %asc, i8 42, i32 4, i1 true)
  %val = load i32, ptr %a
  ret i32 %val
}

; Don't change the address space of a volatile operation
define void @volatile_memcpy(ptr %src, ptr %dst) {
; CHECK-LABEL: @volatile_memcpy(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A_SROA_0:%.*]] = alloca i32, align 4
; CHECK-NEXT:    [[A_SROA_0_0_COPYLOAD:%.*]] = load volatile i32, ptr [[SRC:%.*]], align 1, !tbaa [[TBAA0:![0-9]+]]
; CHECK-NEXT:    [[TMP0:%.*]] = addrspacecast ptr [[A_SROA_0]] to ptr addrspace(1)
; CHECK-NEXT:    store volatile i32 [[A_SROA_0_0_COPYLOAD]], ptr addrspace(1) [[TMP0]], align 4, !tbaa [[TBAA0]]
; CHECK-NEXT:    [[TMP1:%.*]] = addrspacecast ptr [[A_SROA_0]] to ptr addrspace(1)
; CHECK-NEXT:    [[A_SROA_0_0_A_SROA_0_0_COPYLOAD1:%.*]] = load volatile i32, ptr addrspace(1) [[TMP1]], align 4, !tbaa [[TBAA3:![0-9]+]]
; CHECK-NEXT:    store volatile i32 [[A_SROA_0_0_A_SROA_0_0_COPYLOAD1]], ptr [[DST:%.*]], align 1, !tbaa [[TBAA3]]
; CHECK-NEXT:    ret void
;
entry:
  %a = alloca [4 x i8]
  %asc = addrspacecast ptr %a to ptr addrspace(1)
  call void @llvm.memcpy.p1.p0.i32(ptr addrspace(1) %asc, ptr %src, i32 4, i1 true), !tbaa !0
  call void @llvm.memcpy.p0.p1.i32(ptr %dst, ptr addrspace(1) %asc, i32 4, i1 true), !tbaa !3
  ret void
}

define void @select_addrspacecast(i1 %a, i1 %b) {
; CHECK-LABEL: @select_addrspacecast(
; CHECK-NEXT:    ret void
;
  %c = alloca i64, align 8
  %p.0.c = select i1 %a, ptr %c, ptr %c
  %asc = addrspacecast ptr %p.0.c to ptr addrspace(1)

  %cond.in = select i1 %b, ptr addrspace(1) %asc, ptr addrspace(1) %asc
  %cond = load i64, ptr addrspace(1) %cond.in, align 8
  ret void
}

define void @select_addrspacecast_const_op(i1 %a, i1 %b) {
; CHECK-PRESERVE-CFG-LABEL: @select_addrspacecast_const_op(
; CHECK-PRESERVE-CFG-NEXT:    [[C:%.*]] = alloca i64, align 8
; CHECK-PRESERVE-CFG-NEXT:    [[C_0_ASC_SROA_CAST:%.*]] = addrspacecast ptr [[C]] to ptr addrspace(1)
; CHECK-PRESERVE-CFG-NEXT:    [[COND_IN:%.*]] = select i1 [[B:%.*]], ptr addrspace(1) [[C_0_ASC_SROA_CAST]], ptr addrspace(1) null
; CHECK-PRESERVE-CFG-NEXT:    [[COND:%.*]] = load i64, ptr addrspace(1) [[COND_IN]], align 8
; CHECK-PRESERVE-CFG-NEXT:    ret void
;
; CHECK-MODIFY-CFG-LABEL: @select_addrspacecast_const_op(
; CHECK-MODIFY-CFG-NEXT:    br i1 [[B:%.*]], label [[DOTCONT:%.*]], label [[DOTELSE:%.*]]
; CHECK-MODIFY-CFG:       .else:
; CHECK-MODIFY-CFG-NEXT:    [[COND_ELSE_VAL:%.*]] = load i64, ptr addrspace(1) null, align 8
; CHECK-MODIFY-CFG-NEXT:    br label [[DOTCONT]]
; CHECK-MODIFY-CFG:       .cont:
; CHECK-MODIFY-CFG-NEXT:    [[COND:%.*]] = phi i64 [ undef, [[TMP0:%.*]] ], [ [[COND_ELSE_VAL]], [[DOTELSE]] ]
; CHECK-MODIFY-CFG-NEXT:    ret void
;
  %c = alloca i64, align 8
  %p.0.c = select i1 %a, ptr %c, ptr %c
  %asc = addrspacecast ptr %p.0.c to ptr addrspace(1)

  %cond.in = select i1 %b, ptr addrspace(1) %asc, ptr addrspace(1) null
  %cond = load i64, ptr addrspace(1) %cond.in, align 8
  ret void
}

;; If this was external, we wouldn't be able to prove dereferenceability
;; of the location.
@gv = addrspace(1) global i64 zeroinitializer

define void @select_addrspacecast_gv(i1 %a, i1 %b) {
; CHECK-LABEL: @select_addrspacecast_gv(
; CHECK-NEXT:    [[COND_SROA_SPECULATE_LOAD_FALSE:%.*]] = load i64, ptr addrspace(1) @gv, align 8
; CHECK-NEXT:    [[COND_SROA_SPECULATED:%.*]] = select i1 [[B:%.*]], i64 undef, i64 [[COND_SROA_SPECULATE_LOAD_FALSE]]
; CHECK-NEXT:    ret void
;
  %c = alloca i64, align 8
  %p.0.c = select i1 %a, ptr %c, ptr %c
  %asc = addrspacecast ptr %p.0.c to ptr addrspace(1)

  %cond.in = select i1 %b, ptr addrspace(1) %asc, ptr addrspace(1) @gv
  %cond = load i64, ptr addrspace(1) %cond.in, align 8
  ret void
}

define void @select_addrspacecast_gv_constexpr(i1 %a, i1 %b) {
; CHECK-LABEL: @select_addrspacecast_gv_constexpr(
; CHECK-NEXT:    [[COND_SROA_SPECULATE_LOAD_FALSE:%.*]] = load i64, ptr addrspace(2) addrspacecast (ptr addrspace(1) @gv to ptr addrspace(2)), align 8
; CHECK-NEXT:    [[COND_SROA_SPECULATED:%.*]] = select i1 [[B:%.*]], i64 undef, i64 [[COND_SROA_SPECULATE_LOAD_FALSE]]
; CHECK-NEXT:    ret void
;
  %c = alloca i64, align 8
  %p.0.c = select i1 %a, ptr %c, ptr %c
  %asc = addrspacecast ptr %p.0.c to ptr addrspace(2)

  %cond.in = select i1 %b, ptr addrspace(2) %asc, ptr addrspace(2) addrspacecast (ptr addrspace(1) @gv to ptr addrspace(2))
  %cond = load i64, ptr addrspace(2) %cond.in, align 8
  ret void
}

define i8 @select_addrspacecast_i8(i1 %c) {
; CHECK-LABEL: @select_addrspacecast_i8(
; CHECK-NEXT:    [[RET_SROA_SPECULATED:%.*]] = select i1 [[C:%.*]], i8 undef, i8 undef
; CHECK-NEXT:    ret i8 [[RET_SROA_SPECULATED]]
;
  %a = alloca i8
  %b = alloca i8

  %a.ptr = addrspacecast ptr %a to ptr addrspace(1)
  %b.ptr = addrspacecast ptr %b to ptr addrspace(1)

  %ptr = select i1 %c, ptr addrspace(1) %a.ptr, ptr addrspace(1) %b.ptr
  %ret = load i8, ptr addrspace(1) %ptr
  ret i8 %ret
}

!0 = !{!1, !1, i64 0, i64 1}
!1 = !{!2, i64 1, !"type_0"}
!2 = !{!"root"}
!3 = !{!4, !4, i64 0, i64 1}
!4 = !{!2, i64 1, !"type_3"}