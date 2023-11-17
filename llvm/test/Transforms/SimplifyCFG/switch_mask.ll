; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes=simplifycfg --switch-to-lookup -S < %s | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

; https://alive2.llvm.org/ce/z/tuxLhJ
define i1 @switch_lookup_with_small_i1(i64 %x) {
; CHECK-LABEL: @switch_lookup_with_small_i1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[AND:%.*]] = and i64 [[X:%.*]], 15
; CHECK-NEXT:    [[TMP0:%.*]] = icmp ult i64 [[AND]], 11
; CHECK-NEXT:    [[SWITCH_CAST:%.*]] = trunc i64 [[AND]] to i11
; CHECK-NEXT:    [[SWITCH_SHIFTAMT:%.*]] = mul nuw nsw i11 [[SWITCH_CAST]], 1
; CHECK-NEXT:    [[SWITCH_DOWNSHIFT:%.*]] = lshr i11 -1018, [[SWITCH_SHIFTAMT]]
; CHECK-NEXT:    [[SWITCH_MASKED:%.*]] = trunc i11 [[SWITCH_DOWNSHIFT]] to i1
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[TMP0]], i1 [[SWITCH_MASKED]], i1 false
; CHECK-NEXT:    ret i1 [[TMP1]]
;
entry:
  %and = and i64 %x, 15
  switch i64 %and, label %default [
  i64 10, label %lor.end
  i64 1, label %lor.end
  i64 2, label %lor.end
  ]

default:                                          ; preds = %entry
  br label %lor.end

lor.end:                                          ; preds = %entry, %entry, %entry, %default
  %0 = phi i1 [ true, %entry ], [ false, %default ], [ true, %entry ], [ true, %entry ]
  ret i1 %0
}

; https://godbolt.org/z/sjbjorKon
define i8 @switch_lookup_with_small_i8(i64 %x) {
; CHECK-LABEL: @switch_lookup_with_small_i8(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[REM:%.*]] = urem i64 [[X:%.*]], 5
; CHECK-NEXT:    [[TMP0:%.*]] = icmp ult i64 [[REM]], 3
; CHECK-NEXT:    [[SWITCH_CAST:%.*]] = trunc i64 [[REM]] to i24
; CHECK-NEXT:    [[SWITCH_SHIFTAMT:%.*]] = mul nuw nsw i24 [[SWITCH_CAST]], 8
; CHECK-NEXT:    [[SWITCH_DOWNSHIFT:%.*]] = lshr i24 460303, [[SWITCH_SHIFTAMT]]
; CHECK-NEXT:    [[SWITCH_MASKED:%.*]] = trunc i24 [[SWITCH_DOWNSHIFT]] to i8
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[TMP0]], i8 [[SWITCH_MASKED]], i8 0
; CHECK-NEXT:    ret i8 [[TMP1]]
;
entry:
  %rem = urem i64 %x, 5
  switch i64 %rem, label %default [
  i64 0, label %sw.bb0
  i64 1, label %sw.bb1
  i64 2, label %sw.bb2
  ]

sw.bb0:                                           ; preds = %entry
  br label %lor.end

sw.bb1:                                           ; preds = %entry
  br label %lor.end

sw.bb2:                                           ; preds = %entry
  br label %lor.end

default:                                          ; preds = %entry
  br label %lor.end

lor.end:
  %0 = phi i8 [ 15, %sw.bb0 ], [ 6, %sw.bb1 ], [ 7, %sw.bb2 ], [ 0, %default ]
  ret i8 %0
}

; Negative test: Table size would not fit the register.
define i8 @switch_lookup_with_small_i8_negative(i64 %x) {
; CHECK-LABEL: @switch_lookup_with_small_i8_negative(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[REM:%.*]] = urem i64 [[X:%.*]], 9
; CHECK-NEXT:    [[TMP0:%.*]] = icmp ult i64 [[REM]], 3
; CHECK-NEXT:    [[SWITCH_CAST:%.*]] = trunc i64 [[REM]] to i24
; CHECK-NEXT:    [[SWITCH_SHIFTAMT:%.*]] = mul nuw nsw i24 [[SWITCH_CAST]], 8
; CHECK-NEXT:    [[SWITCH_DOWNSHIFT:%.*]] = lshr i24 460303, [[SWITCH_SHIFTAMT]]
; CHECK-NEXT:    [[SWITCH_MASKED:%.*]] = trunc i24 [[SWITCH_DOWNSHIFT]] to i8
; CHECK-NEXT:    [[TMP1:%.*]] = select i1 [[TMP0]], i8 [[SWITCH_MASKED]], i8 0
; CHECK-NEXT:    ret i8 [[TMP1]]
;
entry:
  %rem = urem i64 %x, 9                           ; 9 * 8 = 72 > 64, not fit the register
  switch i64 %rem, label %default [
  i64 0, label %sw.bb0
  i64 1, label %sw.bb1
  i64 2, label %sw.bb2
  ]

sw.bb0:                                           ; preds = %entry
  br label %lor.end

sw.bb1:                                           ; preds = %entry
  br label %lor.end

sw.bb2:                                           ; preds = %entry
  br label %lor.end

default:                                          ; preds = %entry
  br label %lor.end

lor.end:
  %0 = phi i8 [ 15, %sw.bb0 ], [ 6, %sw.bb1 ], [ 7, %sw.bb2 ], [ 0, %default ]
  ret i8 %0
}