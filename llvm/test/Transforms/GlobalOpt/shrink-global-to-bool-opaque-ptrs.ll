; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -passes=globalopt < %s | FileCheck %s

; Make sure we don't try to convert to select if the load/stores don't match
; the global type.

@g1 = internal global i64 zeroinitializer
@g2 = internal global i64 zeroinitializer
@g3 = internal global i64 zeroinitializer

define void @store1() {
; CHECK-LABEL: @store1(
; CHECK-NEXT:    store i32 2, ptr @g1, align 4
; CHECK-NEXT:    ret void
;
  store i32 2, ptr @g1
  ret void
}

define i32 @load1() {
; CHECK-LABEL: @load1(
; CHECK-NEXT:    [[V:%.*]] = load i32, ptr @g1, align 4
; CHECK-NEXT:    ret i32 [[V]]
;
  %v = load i32, ptr @g1
  ret i32 %v
}

define void @store2() {
; CHECK-LABEL: @store2(
; CHECK-NEXT:    store i64 2, ptr @g2, align 4
; CHECK-NEXT:    ret void
;
  store i64 2, ptr @g2
  ret void
}

define i32 @load2() {
; CHECK-LABEL: @load2(
; CHECK-NEXT:    [[V:%.*]] = load i32, ptr @g2, align 4
; CHECK-NEXT:    ret i32 [[V]]
;
  %v = load i32, ptr @g2
  ret i32 %v
}

define void @store3() {
; CHECK-LABEL: @store3(
; CHECK-NEXT:    store i1 true, ptr @g3, align 1
; CHECK-NEXT:    ret void
;
  store i64 2, ptr @g3
  ret void
}

define i64 @load3() {
; CHECK-LABEL: @load3(
; CHECK-NEXT:    [[V_B:%.*]] = load i1, ptr @g3, align 1
; CHECK-NEXT:    [[V:%.*]] = select i1 [[V_B]], i64 2, i64 0
; CHECK-NEXT:    ret i64 [[V]]
;
  %v = load i64, ptr @g3
  ret i64 %v
}
