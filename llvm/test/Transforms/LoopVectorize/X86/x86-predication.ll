; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -mattr=avx -force-vector-width=2 -force-vector-interleave=1 -passes=loop-vectorize,simplifycfg -simplifycfg-require-and-preserve-domtree=1 -S | FileCheck %s
; RUN: opt -mcpu=skylake-avx512 -S -force-vector-width=8 -force-vector-interleave=1 -passes=loop-vectorize < %s | FileCheck %s --check-prefix=SINK-GATHER

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.8.0"

; This test ensures that we don't scalarize the predicated load. Since the load
; can be vectorized with predication, scalarizing it would cause its pointer
; operand to become non-uniform.
;
define i32 @predicated_sdiv_masked_load(ptr %a, ptr %b, i32 %x, i1 %c) {
; CHECK-LABEL: @predicated_sdiv_masked_load(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[BROADCAST_SPLATINSERT:%.*]] = insertelement <2 x i1> poison, i1 [[C:%.*]], i64 0
; CHECK-NEXT:    [[BROADCAST_SPLAT:%.*]] = shufflevector <2 x i1> [[BROADCAST_SPLATINSERT]], <2 x i1> poison, <2 x i32> zeroinitializer
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[INDEX_NEXT:%.*]], [[PRED_SDIV_CONTINUE2:%.*]] ]
; CHECK-NEXT:    [[VEC_PHI:%.*]] = phi <2 x i32> [ zeroinitializer, [[ENTRY]] ], [ [[TMP17:%.*]], [[PRED_SDIV_CONTINUE2]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = add i64 [[INDEX]], 0
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds i32, ptr [[A:%.*]], i64 [[TMP0]]
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i32, ptr [[TMP1]], i32 0
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <2 x i32>, ptr [[TMP2]], align 4
; CHECK-NEXT:    [[TMP3:%.*]] = getelementptr i32, ptr [[B:%.*]], i64 [[TMP0]]
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr i32, ptr [[TMP3]], i32 0
; CHECK-NEXT:    [[WIDE_MASKED_LOAD:%.*]] = call <2 x i32> @llvm.masked.load.v2i32.p0(ptr [[TMP4]], i32 4, <2 x i1> [[BROADCAST_SPLAT]], <2 x i32> poison)
; CHECK-NEXT:    [[TMP5:%.*]] = extractelement <2 x i1> [[BROADCAST_SPLAT]], i32 0
; CHECK-NEXT:    br i1 [[TMP5]], label [[PRED_SDIV_IF:%.*]], label [[PRED_SDIV_CONTINUE:%.*]]
; CHECK:       pred.sdiv.if:
; CHECK-NEXT:    [[TMP6:%.*]] = extractelement <2 x i32> [[WIDE_MASKED_LOAD]], i32 0
; CHECK-NEXT:    [[TMP7:%.*]] = sdiv i32 [[TMP6]], [[X:%.*]]
; CHECK-NEXT:    [[TMP8:%.*]] = insertelement <2 x i32> poison, i32 [[TMP7]], i32 0
; CHECK-NEXT:    br label [[PRED_SDIV_CONTINUE]]
; CHECK:       pred.sdiv.continue:
; CHECK-NEXT:    [[TMP9:%.*]] = phi <2 x i32> [ poison, [[VECTOR_BODY]] ], [ [[TMP8]], [[PRED_SDIV_IF]] ]
; CHECK-NEXT:    [[TMP10:%.*]] = extractelement <2 x i1> [[BROADCAST_SPLAT]], i32 1
; CHECK-NEXT:    br i1 [[TMP10]], label [[PRED_SDIV_IF1:%.*]], label [[PRED_SDIV_CONTINUE2]]
; CHECK:       pred.sdiv.if1:
; CHECK-NEXT:    [[TMP11:%.*]] = extractelement <2 x i32> [[WIDE_MASKED_LOAD]], i32 1
; CHECK-NEXT:    [[TMP12:%.*]] = sdiv i32 [[TMP11]], [[X]]
; CHECK-NEXT:    [[TMP13:%.*]] = insertelement <2 x i32> [[TMP9]], i32 [[TMP12]], i32 1
; CHECK-NEXT:    br label [[PRED_SDIV_CONTINUE2]]
; CHECK:       pred.sdiv.continue2:
; CHECK-NEXT:    [[TMP14:%.*]] = phi <2 x i32> [ [[TMP9]], [[PRED_SDIV_CONTINUE]] ], [ [[TMP13]], [[PRED_SDIV_IF1]] ]
; CHECK-NEXT:    [[TMP15:%.*]] = add nsw <2 x i32> [[TMP14]], [[WIDE_LOAD]]
; CHECK-NEXT:    [[TMP16:%.*]] = xor <2 x i1> [[BROADCAST_SPLAT]], <i1 true, i1 true>
; CHECK-NEXT:    [[PREDPHI:%.*]] = select <2 x i1> [[BROADCAST_SPLAT]], <2 x i32> [[TMP15]], <2 x i32> [[WIDE_LOAD]]
; CHECK-NEXT:    [[TMP17]] = add <2 x i32> [[VEC_PHI]], [[PREDPHI]]
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 2
; CHECK-NEXT:    [[TMP18:%.*]] = icmp eq i64 [[INDEX_NEXT]], 10000
; CHECK-NEXT:    br i1 [[TMP18]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP0:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[TMP19:%.*]] = call i32 @llvm.vector.reduce.add.v2i32(<2 x i32> [[TMP17]])
; CHECK-NEXT:    ret i32 [[TMP19]]
;
; SINK-GATHER-LABEL: @predicated_sdiv_masked_load(
; SINK-GATHER-NEXT:  entry:
; SINK-GATHER-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; SINK-GATHER:       vector.ph:
; SINK-GATHER-NEXT:    [[BROADCAST_SPLATINSERT:%.*]] = insertelement <8 x i1> poison, i1 [[C:%.*]], i64 0
; SINK-GATHER-NEXT:    [[BROADCAST_SPLAT:%.*]] = shufflevector <8 x i1> [[BROADCAST_SPLATINSERT]], <8 x i1> poison, <8 x i32> zeroinitializer
; SINK-GATHER-NEXT:    br label [[VECTOR_BODY:%.*]]
; SINK-GATHER:       vector.body:
; SINK-GATHER-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[PRED_SDIV_CONTINUE14:%.*]] ]
; SINK-GATHER-NEXT:    [[VEC_PHI:%.*]] = phi <8 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP47:%.*]], [[PRED_SDIV_CONTINUE14]] ]
; SINK-GATHER-NEXT:    [[TMP0:%.*]] = add i64 [[INDEX]], 0
; SINK-GATHER-NEXT:    [[TMP1:%.*]] = getelementptr inbounds i32, ptr [[A:%.*]], i64 [[TMP0]]
; SINK-GATHER-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i32, ptr [[TMP1]], i32 0
; SINK-GATHER-NEXT:    [[WIDE_LOAD:%.*]] = load <8 x i32>, ptr [[TMP2]], align 4
; SINK-GATHER-NEXT:    [[TMP3:%.*]] = getelementptr i32, ptr [[B:%.*]], i64 [[TMP0]]
; SINK-GATHER-NEXT:    [[TMP4:%.*]] = getelementptr i32, ptr [[TMP3]], i32 0
; SINK-GATHER-NEXT:    [[WIDE_MASKED_LOAD:%.*]] = call <8 x i32> @llvm.masked.load.v8i32.p0(ptr [[TMP4]], i32 4, <8 x i1> [[BROADCAST_SPLAT]], <8 x i32> poison)
; SINK-GATHER-NEXT:    [[TMP5:%.*]] = extractelement <8 x i1> [[BROADCAST_SPLAT]], i32 0
; SINK-GATHER-NEXT:    br i1 [[TMP5]], label [[PRED_SDIV_IF:%.*]], label [[PRED_SDIV_CONTINUE:%.*]]
; SINK-GATHER:       pred.sdiv.if:
; SINK-GATHER-NEXT:    [[TMP6:%.*]] = extractelement <8 x i32> [[WIDE_MASKED_LOAD]], i32 0
; SINK-GATHER-NEXT:    [[TMP7:%.*]] = sdiv i32 [[TMP6]], [[X:%.*]]
; SINK-GATHER-NEXT:    [[TMP8:%.*]] = insertelement <8 x i32> poison, i32 [[TMP7]], i32 0
; SINK-GATHER-NEXT:    br label [[PRED_SDIV_CONTINUE]]
; SINK-GATHER:       pred.sdiv.continue:
; SINK-GATHER-NEXT:    [[TMP9:%.*]] = phi <8 x i32> [ poison, [[VECTOR_BODY]] ], [ [[TMP8]], [[PRED_SDIV_IF]] ]
; SINK-GATHER-NEXT:    [[TMP10:%.*]] = extractelement <8 x i1> [[BROADCAST_SPLAT]], i32 1
; SINK-GATHER-NEXT:    br i1 [[TMP10]], label [[PRED_SDIV_IF1:%.*]], label [[PRED_SDIV_CONTINUE2:%.*]]
; SINK-GATHER:       pred.sdiv.if1:
; SINK-GATHER-NEXT:    [[TMP11:%.*]] = extractelement <8 x i32> [[WIDE_MASKED_LOAD]], i32 1
; SINK-GATHER-NEXT:    [[TMP12:%.*]] = sdiv i32 [[TMP11]], [[X]]
; SINK-GATHER-NEXT:    [[TMP13:%.*]] = insertelement <8 x i32> [[TMP9]], i32 [[TMP12]], i32 1
; SINK-GATHER-NEXT:    br label [[PRED_SDIV_CONTINUE2]]
; SINK-GATHER:       pred.sdiv.continue2:
; SINK-GATHER-NEXT:    [[TMP14:%.*]] = phi <8 x i32> [ [[TMP9]], [[PRED_SDIV_CONTINUE]] ], [ [[TMP13]], [[PRED_SDIV_IF1]] ]
; SINK-GATHER-NEXT:    [[TMP15:%.*]] = extractelement <8 x i1> [[BROADCAST_SPLAT]], i32 2
; SINK-GATHER-NEXT:    br i1 [[TMP15]], label [[PRED_SDIV_IF3:%.*]], label [[PRED_SDIV_CONTINUE4:%.*]]
; SINK-GATHER:       pred.sdiv.if3:
; SINK-GATHER-NEXT:    [[TMP16:%.*]] = extractelement <8 x i32> [[WIDE_MASKED_LOAD]], i32 2
; SINK-GATHER-NEXT:    [[TMP17:%.*]] = sdiv i32 [[TMP16]], [[X]]
; SINK-GATHER-NEXT:    [[TMP18:%.*]] = insertelement <8 x i32> [[TMP14]], i32 [[TMP17]], i32 2
; SINK-GATHER-NEXT:    br label [[PRED_SDIV_CONTINUE4]]
; SINK-GATHER:       pred.sdiv.continue4:
; SINK-GATHER-NEXT:    [[TMP19:%.*]] = phi <8 x i32> [ [[TMP14]], [[PRED_SDIV_CONTINUE2]] ], [ [[TMP18]], [[PRED_SDIV_IF3]] ]
; SINK-GATHER-NEXT:    [[TMP20:%.*]] = extractelement <8 x i1> [[BROADCAST_SPLAT]], i32 3
; SINK-GATHER-NEXT:    br i1 [[TMP20]], label [[PRED_SDIV_IF5:%.*]], label [[PRED_SDIV_CONTINUE6:%.*]]
; SINK-GATHER:       pred.sdiv.if5:
; SINK-GATHER-NEXT:    [[TMP21:%.*]] = extractelement <8 x i32> [[WIDE_MASKED_LOAD]], i32 3
; SINK-GATHER-NEXT:    [[TMP22:%.*]] = sdiv i32 [[TMP21]], [[X]]
; SINK-GATHER-NEXT:    [[TMP23:%.*]] = insertelement <8 x i32> [[TMP19]], i32 [[TMP22]], i32 3
; SINK-GATHER-NEXT:    br label [[PRED_SDIV_CONTINUE6]]
; SINK-GATHER:       pred.sdiv.continue6:
; SINK-GATHER-NEXT:    [[TMP24:%.*]] = phi <8 x i32> [ [[TMP19]], [[PRED_SDIV_CONTINUE4]] ], [ [[TMP23]], [[PRED_SDIV_IF5]] ]
; SINK-GATHER-NEXT:    [[TMP25:%.*]] = extractelement <8 x i1> [[BROADCAST_SPLAT]], i32 4
; SINK-GATHER-NEXT:    br i1 [[TMP25]], label [[PRED_SDIV_IF7:%.*]], label [[PRED_SDIV_CONTINUE8:%.*]]
; SINK-GATHER:       pred.sdiv.if7:
; SINK-GATHER-NEXT:    [[TMP26:%.*]] = extractelement <8 x i32> [[WIDE_MASKED_LOAD]], i32 4
; SINK-GATHER-NEXT:    [[TMP27:%.*]] = sdiv i32 [[TMP26]], [[X]]
; SINK-GATHER-NEXT:    [[TMP28:%.*]] = insertelement <8 x i32> [[TMP24]], i32 [[TMP27]], i32 4
; SINK-GATHER-NEXT:    br label [[PRED_SDIV_CONTINUE8]]
; SINK-GATHER:       pred.sdiv.continue8:
; SINK-GATHER-NEXT:    [[TMP29:%.*]] = phi <8 x i32> [ [[TMP24]], [[PRED_SDIV_CONTINUE6]] ], [ [[TMP28]], [[PRED_SDIV_IF7]] ]
; SINK-GATHER-NEXT:    [[TMP30:%.*]] = extractelement <8 x i1> [[BROADCAST_SPLAT]], i32 5
; SINK-GATHER-NEXT:    br i1 [[TMP30]], label [[PRED_SDIV_IF9:%.*]], label [[PRED_SDIV_CONTINUE10:%.*]]
; SINK-GATHER:       pred.sdiv.if9:
; SINK-GATHER-NEXT:    [[TMP31:%.*]] = extractelement <8 x i32> [[WIDE_MASKED_LOAD]], i32 5
; SINK-GATHER-NEXT:    [[TMP32:%.*]] = sdiv i32 [[TMP31]], [[X]]
; SINK-GATHER-NEXT:    [[TMP33:%.*]] = insertelement <8 x i32> [[TMP29]], i32 [[TMP32]], i32 5
; SINK-GATHER-NEXT:    br label [[PRED_SDIV_CONTINUE10]]
; SINK-GATHER:       pred.sdiv.continue10:
; SINK-GATHER-NEXT:    [[TMP34:%.*]] = phi <8 x i32> [ [[TMP29]], [[PRED_SDIV_CONTINUE8]] ], [ [[TMP33]], [[PRED_SDIV_IF9]] ]
; SINK-GATHER-NEXT:    [[TMP35:%.*]] = extractelement <8 x i1> [[BROADCAST_SPLAT]], i32 6
; SINK-GATHER-NEXT:    br i1 [[TMP35]], label [[PRED_SDIV_IF11:%.*]], label [[PRED_SDIV_CONTINUE12:%.*]]
; SINK-GATHER:       pred.sdiv.if11:
; SINK-GATHER-NEXT:    [[TMP36:%.*]] = extractelement <8 x i32> [[WIDE_MASKED_LOAD]], i32 6
; SINK-GATHER-NEXT:    [[TMP37:%.*]] = sdiv i32 [[TMP36]], [[X]]
; SINK-GATHER-NEXT:    [[TMP38:%.*]] = insertelement <8 x i32> [[TMP34]], i32 [[TMP37]], i32 6
; SINK-GATHER-NEXT:    br label [[PRED_SDIV_CONTINUE12]]
; SINK-GATHER:       pred.sdiv.continue12:
; SINK-GATHER-NEXT:    [[TMP39:%.*]] = phi <8 x i32> [ [[TMP34]], [[PRED_SDIV_CONTINUE10]] ], [ [[TMP38]], [[PRED_SDIV_IF11]] ]
; SINK-GATHER-NEXT:    [[TMP40:%.*]] = extractelement <8 x i1> [[BROADCAST_SPLAT]], i32 7
; SINK-GATHER-NEXT:    br i1 [[TMP40]], label [[PRED_SDIV_IF13:%.*]], label [[PRED_SDIV_CONTINUE14]]
; SINK-GATHER:       pred.sdiv.if13:
; SINK-GATHER-NEXT:    [[TMP41:%.*]] = extractelement <8 x i32> [[WIDE_MASKED_LOAD]], i32 7
; SINK-GATHER-NEXT:    [[TMP42:%.*]] = sdiv i32 [[TMP41]], [[X]]
; SINK-GATHER-NEXT:    [[TMP43:%.*]] = insertelement <8 x i32> [[TMP39]], i32 [[TMP42]], i32 7
; SINK-GATHER-NEXT:    br label [[PRED_SDIV_CONTINUE14]]
; SINK-GATHER:       pred.sdiv.continue14:
; SINK-GATHER-NEXT:    [[TMP44:%.*]] = phi <8 x i32> [ [[TMP39]], [[PRED_SDIV_CONTINUE12]] ], [ [[TMP43]], [[PRED_SDIV_IF13]] ]
; SINK-GATHER-NEXT:    [[TMP45:%.*]] = add nsw <8 x i32> [[TMP44]], [[WIDE_LOAD]]
; SINK-GATHER-NEXT:    [[TMP46:%.*]] = xor <8 x i1> [[BROADCAST_SPLAT]], <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>
; SINK-GATHER-NEXT:    [[PREDPHI:%.*]] = select <8 x i1> [[BROADCAST_SPLAT]], <8 x i32> [[TMP45]], <8 x i32> [[WIDE_LOAD]]
; SINK-GATHER-NEXT:    [[TMP47]] = add <8 x i32> [[VEC_PHI]], [[PREDPHI]]
; SINK-GATHER-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 8
; SINK-GATHER-NEXT:    [[TMP48:%.*]] = icmp eq i64 [[INDEX_NEXT]], 10000
; SINK-GATHER-NEXT:    br i1 [[TMP48]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP0:![0-9]+]]
; SINK-GATHER:       middle.block:
; SINK-GATHER-NEXT:    [[TMP49:%.*]] = call i32 @llvm.vector.reduce.add.v8i32(<8 x i32> [[TMP47]])
; SINK-GATHER-NEXT:    br i1 true, label [[FOR_END:%.*]], label [[SCALAR_PH]]
; SINK-GATHER:       scalar.ph:
; SINK-GATHER-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ 10000, [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; SINK-GATHER-NEXT:    [[BC_MERGE_RDX:%.*]] = phi i32 [ 0, [[ENTRY]] ], [ [[TMP49]], [[MIDDLE_BLOCK]] ]
; SINK-GATHER-NEXT:    br label [[FOR_BODY:%.*]]
; SINK-GATHER:       for.body:
; SINK-GATHER-NEXT:    [[I:%.*]] = phi i64 [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ], [ [[I_NEXT:%.*]], [[FOR_INC:%.*]] ]
; SINK-GATHER-NEXT:    [[R:%.*]] = phi i32 [ [[BC_MERGE_RDX]], [[SCALAR_PH]] ], [ [[T7:%.*]], [[FOR_INC]] ]
; SINK-GATHER-NEXT:    [[T0:%.*]] = getelementptr inbounds i32, ptr [[A]], i64 [[I]]
; SINK-GATHER-NEXT:    [[T1:%.*]] = load i32, ptr [[T0]], align 4
; SINK-GATHER-NEXT:    br i1 [[C]], label [[IF_THEN:%.*]], label [[FOR_INC]]
; SINK-GATHER:       if.then:
; SINK-GATHER-NEXT:    [[T2:%.*]] = getelementptr inbounds i32, ptr [[B]], i64 [[I]]
; SINK-GATHER-NEXT:    [[T3:%.*]] = load i32, ptr [[T2]], align 4
; SINK-GATHER-NEXT:    [[T4:%.*]] = sdiv i32 [[T3]], [[X]]
; SINK-GATHER-NEXT:    [[T5:%.*]] = add nsw i32 [[T4]], [[T1]]
; SINK-GATHER-NEXT:    br label [[FOR_INC]]
; SINK-GATHER:       for.inc:
; SINK-GATHER-NEXT:    [[T6:%.*]] = phi i32 [ [[T1]], [[FOR_BODY]] ], [ [[T5]], [[IF_THEN]] ]
; SINK-GATHER-NEXT:    [[T7]] = add i32 [[R]], [[T6]]
; SINK-GATHER-NEXT:    [[I_NEXT]] = add nuw nsw i64 [[I]], 1
; SINK-GATHER-NEXT:    [[COND:%.*]] = icmp eq i64 [[I_NEXT]], 10000
; SINK-GATHER-NEXT:    br i1 [[COND]], label [[FOR_END]], label [[FOR_BODY]], !llvm.loop [[LOOP3:![0-9]+]]
; SINK-GATHER:       for.end:
; SINK-GATHER-NEXT:    [[T8:%.*]] = phi i32 [ [[T7]], [[FOR_INC]] ], [ [[TMP49]], [[MIDDLE_BLOCK]] ]
; SINK-GATHER-NEXT:    ret i32 [[T8]]
;
entry:
  br label %for.body

for.body:
  %i = phi i64 [ 0, %entry ], [ %i.next, %for.inc ]
  %r = phi i32 [ 0, %entry ], [ %t7, %for.inc ]
  %t0 = getelementptr inbounds i32, ptr %a, i64 %i
  %t1 = load i32, ptr %t0, align 4
  br i1 %c, label %if.then, label %for.inc

if.then:
  %t2 = getelementptr inbounds i32, ptr %b, i64 %i
  %t3 = load i32, ptr %t2, align 4
  %t4 = sdiv i32 %t3, %x
  %t5 = add nsw i32 %t4, %t1
  br label %for.inc

for.inc:
  %t6 = phi i32 [ %t1, %for.body ], [ %t5, %if.then]
  %t7 = add i32 %r, %t6
  %i.next = add nuw nsw i64 %i, 1
  %cond = icmp eq i64 %i.next, 10000
  br i1 %cond, label %for.end, label %for.body

for.end:
  %t8 = phi i32 [ %t7, %for.inc ]
  ret i32 %t8
}

; This test ensures that a load, which would have been widened otherwise is
; instead scalarized if Cost-Model so decided as part of its
; sink-scalar-operands optimization for predicated instructions.
define i32 @scalarize_and_sink_gather(ptr %a, i1 %c, i32 %x, i64 %n) {
; CHECK-LABEL: @scalarize_and_sink_gather(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SMAX:%.*]] = call i64 @llvm.smax.i64(i64 [[N:%.*]], i64 1)
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ult i64 [[SMAX]], 2
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 [[SMAX]], 2
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i64 [[SMAX]], [[N_MOD_VF]]
; CHECK-NEXT:    [[BROADCAST_SPLATINSERT:%.*]] = insertelement <2 x i1> poison, i1 [[C:%.*]], i64 0
; CHECK-NEXT:    [[BROADCAST_SPLAT:%.*]] = shufflevector <2 x i1> [[BROADCAST_SPLATINSERT]], <2 x i1> poison, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[BROADCAST_SPLATINSERT3:%.*]] = insertelement <2 x i32> poison, i32 [[X:%.*]], i64 0
; CHECK-NEXT:    [[BROADCAST_SPLAT4:%.*]] = shufflevector <2 x i32> [[BROADCAST_SPLATINSERT3]], <2 x i32> poison, <2 x i32> zeroinitializer
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[PRED_UDIV_CONTINUE2:%.*]] ]
; CHECK-NEXT:    [[VEC_IND:%.*]] = phi <2 x i64> [ <i64 0, i64 1>, [[VECTOR_PH]] ], [ [[VEC_IND_NEXT:%.*]], [[PRED_UDIV_CONTINUE2]] ]
; CHECK-NEXT:    [[VEC_PHI:%.*]] = phi <2 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP18:%.*]], [[PRED_UDIV_CONTINUE2]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = mul <2 x i64> [[VEC_IND]], <i64 777, i64 777>
; CHECK-NEXT:    [[TMP1:%.*]] = extractelement <2 x i1> [[BROADCAST_SPLAT]], i32 0
; CHECK-NEXT:    br i1 [[TMP1]], label [[PRED_UDIV_IF:%.*]], label [[PRED_UDIV_CONTINUE:%.*]]
; CHECK:       pred.udiv.if:
; CHECK-NEXT:    [[TMP2:%.*]] = extractelement <2 x i64> [[TMP0]], i32 0
; CHECK-NEXT:    [[TMP3:%.*]] = getelementptr inbounds i32, ptr [[A:%.*]], i64 [[TMP2]]
; CHECK-NEXT:    [[TMP4:%.*]] = load i32, ptr [[TMP3]], align 4
; CHECK-NEXT:    [[TMP5:%.*]] = udiv i32 [[TMP4]], [[X]]
; CHECK-NEXT:    [[TMP6:%.*]] = insertelement <2 x i32> poison, i32 [[TMP5]], i32 0
; CHECK-NEXT:    br label [[PRED_UDIV_CONTINUE]]
; CHECK:       pred.udiv.continue:
; CHECK-NEXT:    [[TMP7:%.*]] = phi i32 [ poison, [[VECTOR_BODY]] ], [ [[TMP4]], [[PRED_UDIV_IF]] ]
; CHECK-NEXT:    [[TMP8:%.*]] = phi <2 x i32> [ poison, [[VECTOR_BODY]] ], [ [[TMP6]], [[PRED_UDIV_IF]] ]
; CHECK-NEXT:    [[TMP9:%.*]] = extractelement <2 x i1> [[BROADCAST_SPLAT]], i32 1
; CHECK-NEXT:    br i1 [[TMP9]], label [[PRED_UDIV_IF1:%.*]], label [[PRED_UDIV_CONTINUE2]]
; CHECK:       pred.udiv.if1:
; CHECK-NEXT:    [[TMP10:%.*]] = extractelement <2 x i64> [[TMP0]], i32 1
; CHECK-NEXT:    [[TMP11:%.*]] = getelementptr inbounds i32, ptr [[A]], i64 [[TMP10]]
; CHECK-NEXT:    [[TMP12:%.*]] = load i32, ptr [[TMP11]], align 4
; CHECK-NEXT:    [[TMP13:%.*]] = udiv i32 [[TMP12]], [[X]]
; CHECK-NEXT:    [[TMP14:%.*]] = insertelement <2 x i32> [[TMP8]], i32 [[TMP13]], i32 1
; CHECK-NEXT:    br label [[PRED_UDIV_CONTINUE2]]
; CHECK:       pred.udiv.continue2:
; CHECK-NEXT:    [[TMP15:%.*]] = phi i32 [ poison, [[PRED_UDIV_CONTINUE]] ], [ [[TMP12]], [[PRED_UDIV_IF1]] ]
; CHECK-NEXT:    [[TMP16:%.*]] = phi <2 x i32> [ [[TMP8]], [[PRED_UDIV_CONTINUE]] ], [ [[TMP14]], [[PRED_UDIV_IF1]] ]
; CHECK-NEXT:    [[TMP17:%.*]] = xor <2 x i1> [[BROADCAST_SPLAT]], <i1 true, i1 true>
; CHECK-NEXT:    [[PREDPHI:%.*]] = select <2 x i1> [[BROADCAST_SPLAT]], <2 x i32> [[TMP16]], <2 x i32> [[BROADCAST_SPLAT4]]
; CHECK-NEXT:    [[TMP18]] = add <2 x i32> [[VEC_PHI]], [[PREDPHI]]
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 2
; CHECK-NEXT:    [[VEC_IND_NEXT]] = add <2 x i64> [[VEC_IND]], <i64 2, i64 2>
; CHECK-NEXT:    [[TMP19:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP19]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP3:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[TMP20:%.*]] = call i32 @llvm.vector.reduce.add.v2i32(<2 x i32> [[TMP18]])
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[SMAX]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N]], label [[FOR_END:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC]], [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[BC_MERGE_RDX:%.*]] = phi i32 [ 0, [[ENTRY]] ], [ [[TMP20]], [[MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[I:%.*]] = phi i64 [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ], [ [[I_NEXT:%.*]], [[FOR_INC:%.*]] ]
; CHECK-NEXT:    [[R:%.*]] = phi i32 [ [[BC_MERGE_RDX]], [[SCALAR_PH]] ], [ [[T6:%.*]], [[FOR_INC]] ]
; CHECK-NEXT:    [[I7:%.*]] = mul i64 [[I]], 777
; CHECK-NEXT:    br i1 [[C]], label [[IF_THEN:%.*]], label [[FOR_INC]]
; CHECK:       if.then:
; CHECK-NEXT:    [[T0:%.*]] = getelementptr inbounds i32, ptr [[A]], i64 [[I7]]
; CHECK-NEXT:    [[T2:%.*]] = load i32, ptr [[T0]], align 4
; CHECK-NEXT:    [[T4:%.*]] = udiv i32 [[T2]], [[X]]
; CHECK-NEXT:    br label [[FOR_INC]]
; CHECK:       for.inc:
; CHECK-NEXT:    [[T5:%.*]] = phi i32 [ [[X]], [[FOR_BODY]] ], [ [[T4]], [[IF_THEN]] ]
; CHECK-NEXT:    [[T6]] = add i32 [[R]], [[T5]]
; CHECK-NEXT:    [[I_NEXT]] = add nuw nsw i64 [[I]], 1
; CHECK-NEXT:    [[COND:%.*]] = icmp slt i64 [[I_NEXT]], [[N]]
; CHECK-NEXT:    br i1 [[COND]], label [[FOR_BODY]], label [[FOR_END]], !llvm.loop [[LOOP4:![0-9]+]]
; CHECK:       for.end:
; CHECK-NEXT:    [[T7:%.*]] = phi i32 [ [[T6]], [[FOR_INC]] ], [ [[TMP20]], [[MIDDLE_BLOCK]] ]
; CHECK-NEXT:    ret i32 [[T7]]
;
; SINK-GATHER-LABEL: @scalarize_and_sink_gather(
; SINK-GATHER-NEXT:  entry:
; SINK-GATHER-NEXT:    [[SMAX:%.*]] = call i64 @llvm.smax.i64(i64 [[N:%.*]], i64 1)
; SINK-GATHER-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ult i64 [[SMAX]], 8
; SINK-GATHER-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; SINK-GATHER:       vector.ph:
; SINK-GATHER-NEXT:    [[N_MOD_VF:%.*]] = urem i64 [[SMAX]], 8
; SINK-GATHER-NEXT:    [[N_VEC:%.*]] = sub i64 [[SMAX]], [[N_MOD_VF]]
; SINK-GATHER-NEXT:    [[BROADCAST_SPLATINSERT:%.*]] = insertelement <8 x i1> poison, i1 [[C:%.*]], i64 0
; SINK-GATHER-NEXT:    [[BROADCAST_SPLAT:%.*]] = shufflevector <8 x i1> [[BROADCAST_SPLATINSERT]], <8 x i1> poison, <8 x i32> zeroinitializer
; SINK-GATHER-NEXT:    [[BROADCAST_SPLATINSERT15:%.*]] = insertelement <8 x i32> poison, i32 [[X:%.*]], i64 0
; SINK-GATHER-NEXT:    [[BROADCAST_SPLAT16:%.*]] = shufflevector <8 x i32> [[BROADCAST_SPLATINSERT15]], <8 x i32> poison, <8 x i32> zeroinitializer
; SINK-GATHER-NEXT:    br label [[VECTOR_BODY:%.*]]
; SINK-GATHER:       vector.body:
; SINK-GATHER-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[PRED_UDIV_CONTINUE14:%.*]] ]
; SINK-GATHER-NEXT:    [[VEC_IND:%.*]] = phi <8 x i64> [ <i64 0, i64 1, i64 2, i64 3, i64 4, i64 5, i64 6, i64 7>, [[VECTOR_PH]] ], [ [[VEC_IND_NEXT:%.*]], [[PRED_UDIV_CONTINUE14]] ]
; SINK-GATHER-NEXT:    [[VEC_PHI:%.*]] = phi <8 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP66:%.*]], [[PRED_UDIV_CONTINUE14]] ]
; SINK-GATHER-NEXT:    [[TMP0:%.*]] = mul <8 x i64> [[VEC_IND]], <i64 777, i64 777, i64 777, i64 777, i64 777, i64 777, i64 777, i64 777>
; SINK-GATHER-NEXT:    [[TMP1:%.*]] = extractelement <8 x i1> [[BROADCAST_SPLAT]], i32 0
; SINK-GATHER-NEXT:    br i1 [[TMP1]], label [[PRED_UDIV_IF:%.*]], label [[PRED_UDIV_CONTINUE:%.*]]
; SINK-GATHER:       pred.udiv.if:
; SINK-GATHER-NEXT:    [[TMP2:%.*]] = extractelement <8 x i64> [[TMP0]], i32 0
; SINK-GATHER-NEXT:    [[TMP3:%.*]] = getelementptr inbounds i32, ptr [[A:%.*]], i64 [[TMP2]]
; SINK-GATHER-NEXT:    [[TMP4:%.*]] = load i32, ptr [[TMP3]], align 4
; SINK-GATHER-NEXT:    [[TMP5:%.*]] = udiv i32 [[TMP4]], [[X]]
; SINK-GATHER-NEXT:    [[TMP6:%.*]] = insertelement <8 x i32> poison, i32 [[TMP5]], i32 0
; SINK-GATHER-NEXT:    br label [[PRED_UDIV_CONTINUE]]
; SINK-GATHER:       pred.udiv.continue:
; SINK-GATHER-NEXT:    [[TMP7:%.*]] = phi i32 [ poison, [[VECTOR_BODY]] ], [ [[TMP4]], [[PRED_UDIV_IF]] ]
; SINK-GATHER-NEXT:    [[TMP8:%.*]] = phi <8 x i32> [ poison, [[VECTOR_BODY]] ], [ [[TMP6]], [[PRED_UDIV_IF]] ]
; SINK-GATHER-NEXT:    [[TMP9:%.*]] = extractelement <8 x i1> [[BROADCAST_SPLAT]], i32 1
; SINK-GATHER-NEXT:    br i1 [[TMP9]], label [[PRED_UDIV_IF1:%.*]], label [[PRED_UDIV_CONTINUE2:%.*]]
; SINK-GATHER:       pred.udiv.if1:
; SINK-GATHER-NEXT:    [[TMP10:%.*]] = extractelement <8 x i64> [[TMP0]], i32 1
; SINK-GATHER-NEXT:    [[TMP11:%.*]] = getelementptr inbounds i32, ptr [[A]], i64 [[TMP10]]
; SINK-GATHER-NEXT:    [[TMP12:%.*]] = load i32, ptr [[TMP11]], align 4
; SINK-GATHER-NEXT:    [[TMP13:%.*]] = udiv i32 [[TMP12]], [[X]]
; SINK-GATHER-NEXT:    [[TMP14:%.*]] = insertelement <8 x i32> [[TMP8]], i32 [[TMP13]], i32 1
; SINK-GATHER-NEXT:    br label [[PRED_UDIV_CONTINUE2]]
; SINK-GATHER:       pred.udiv.continue2:
; SINK-GATHER-NEXT:    [[TMP15:%.*]] = phi i32 [ poison, [[PRED_UDIV_CONTINUE]] ], [ [[TMP12]], [[PRED_UDIV_IF1]] ]
; SINK-GATHER-NEXT:    [[TMP16:%.*]] = phi <8 x i32> [ [[TMP8]], [[PRED_UDIV_CONTINUE]] ], [ [[TMP14]], [[PRED_UDIV_IF1]] ]
; SINK-GATHER-NEXT:    [[TMP17:%.*]] = extractelement <8 x i1> [[BROADCAST_SPLAT]], i32 2
; SINK-GATHER-NEXT:    br i1 [[TMP17]], label [[PRED_UDIV_IF3:%.*]], label [[PRED_UDIV_CONTINUE4:%.*]]
; SINK-GATHER:       pred.udiv.if3:
; SINK-GATHER-NEXT:    [[TMP18:%.*]] = extractelement <8 x i64> [[TMP0]], i32 2
; SINK-GATHER-NEXT:    [[TMP19:%.*]] = getelementptr inbounds i32, ptr [[A]], i64 [[TMP18]]
; SINK-GATHER-NEXT:    [[TMP20:%.*]] = load i32, ptr [[TMP19]], align 4
; SINK-GATHER-NEXT:    [[TMP21:%.*]] = udiv i32 [[TMP20]], [[X]]
; SINK-GATHER-NEXT:    [[TMP22:%.*]] = insertelement <8 x i32> [[TMP16]], i32 [[TMP21]], i32 2
; SINK-GATHER-NEXT:    br label [[PRED_UDIV_CONTINUE4]]
; SINK-GATHER:       pred.udiv.continue4:
; SINK-GATHER-NEXT:    [[TMP23:%.*]] = phi i32 [ poison, [[PRED_UDIV_CONTINUE2]] ], [ [[TMP20]], [[PRED_UDIV_IF3]] ]
; SINK-GATHER-NEXT:    [[TMP24:%.*]] = phi <8 x i32> [ [[TMP16]], [[PRED_UDIV_CONTINUE2]] ], [ [[TMP22]], [[PRED_UDIV_IF3]] ]
; SINK-GATHER-NEXT:    [[TMP25:%.*]] = extractelement <8 x i1> [[BROADCAST_SPLAT]], i32 3
; SINK-GATHER-NEXT:    br i1 [[TMP25]], label [[PRED_UDIV_IF5:%.*]], label [[PRED_UDIV_CONTINUE6:%.*]]
; SINK-GATHER:       pred.udiv.if5:
; SINK-GATHER-NEXT:    [[TMP26:%.*]] = extractelement <8 x i64> [[TMP0]], i32 3
; SINK-GATHER-NEXT:    [[TMP27:%.*]] = getelementptr inbounds i32, ptr [[A]], i64 [[TMP26]]
; SINK-GATHER-NEXT:    [[TMP28:%.*]] = load i32, ptr [[TMP27]], align 4
; SINK-GATHER-NEXT:    [[TMP29:%.*]] = udiv i32 [[TMP28]], [[X]]
; SINK-GATHER-NEXT:    [[TMP30:%.*]] = insertelement <8 x i32> [[TMP24]], i32 [[TMP29]], i32 3
; SINK-GATHER-NEXT:    br label [[PRED_UDIV_CONTINUE6]]
; SINK-GATHER:       pred.udiv.continue6:
; SINK-GATHER-NEXT:    [[TMP31:%.*]] = phi i32 [ poison, [[PRED_UDIV_CONTINUE4]] ], [ [[TMP28]], [[PRED_UDIV_IF5]] ]
; SINK-GATHER-NEXT:    [[TMP32:%.*]] = phi <8 x i32> [ [[TMP24]], [[PRED_UDIV_CONTINUE4]] ], [ [[TMP30]], [[PRED_UDIV_IF5]] ]
; SINK-GATHER-NEXT:    [[TMP33:%.*]] = extractelement <8 x i1> [[BROADCAST_SPLAT]], i32 4
; SINK-GATHER-NEXT:    br i1 [[TMP33]], label [[PRED_UDIV_IF7:%.*]], label [[PRED_UDIV_CONTINUE8:%.*]]
; SINK-GATHER:       pred.udiv.if7:
; SINK-GATHER-NEXT:    [[TMP34:%.*]] = extractelement <8 x i64> [[TMP0]], i32 4
; SINK-GATHER-NEXT:    [[TMP35:%.*]] = getelementptr inbounds i32, ptr [[A]], i64 [[TMP34]]
; SINK-GATHER-NEXT:    [[TMP36:%.*]] = load i32, ptr [[TMP35]], align 4
; SINK-GATHER-NEXT:    [[TMP37:%.*]] = udiv i32 [[TMP36]], [[X]]
; SINK-GATHER-NEXT:    [[TMP38:%.*]] = insertelement <8 x i32> [[TMP32]], i32 [[TMP37]], i32 4
; SINK-GATHER-NEXT:    br label [[PRED_UDIV_CONTINUE8]]
; SINK-GATHER:       pred.udiv.continue8:
; SINK-GATHER-NEXT:    [[TMP39:%.*]] = phi i32 [ poison, [[PRED_UDIV_CONTINUE6]] ], [ [[TMP36]], [[PRED_UDIV_IF7]] ]
; SINK-GATHER-NEXT:    [[TMP40:%.*]] = phi <8 x i32> [ [[TMP32]], [[PRED_UDIV_CONTINUE6]] ], [ [[TMP38]], [[PRED_UDIV_IF7]] ]
; SINK-GATHER-NEXT:    [[TMP41:%.*]] = extractelement <8 x i1> [[BROADCAST_SPLAT]], i32 5
; SINK-GATHER-NEXT:    br i1 [[TMP41]], label [[PRED_UDIV_IF9:%.*]], label [[PRED_UDIV_CONTINUE10:%.*]]
; SINK-GATHER:       pred.udiv.if9:
; SINK-GATHER-NEXT:    [[TMP42:%.*]] = extractelement <8 x i64> [[TMP0]], i32 5
; SINK-GATHER-NEXT:    [[TMP43:%.*]] = getelementptr inbounds i32, ptr [[A]], i64 [[TMP42]]
; SINK-GATHER-NEXT:    [[TMP44:%.*]] = load i32, ptr [[TMP43]], align 4
; SINK-GATHER-NEXT:    [[TMP45:%.*]] = udiv i32 [[TMP44]], [[X]]
; SINK-GATHER-NEXT:    [[TMP46:%.*]] = insertelement <8 x i32> [[TMP40]], i32 [[TMP45]], i32 5
; SINK-GATHER-NEXT:    br label [[PRED_UDIV_CONTINUE10]]
; SINK-GATHER:       pred.udiv.continue10:
; SINK-GATHER-NEXT:    [[TMP47:%.*]] = phi i32 [ poison, [[PRED_UDIV_CONTINUE8]] ], [ [[TMP44]], [[PRED_UDIV_IF9]] ]
; SINK-GATHER-NEXT:    [[TMP48:%.*]] = phi <8 x i32> [ [[TMP40]], [[PRED_UDIV_CONTINUE8]] ], [ [[TMP46]], [[PRED_UDIV_IF9]] ]
; SINK-GATHER-NEXT:    [[TMP49:%.*]] = extractelement <8 x i1> [[BROADCAST_SPLAT]], i32 6
; SINK-GATHER-NEXT:    br i1 [[TMP49]], label [[PRED_UDIV_IF11:%.*]], label [[PRED_UDIV_CONTINUE12:%.*]]
; SINK-GATHER:       pred.udiv.if11:
; SINK-GATHER-NEXT:    [[TMP50:%.*]] = extractelement <8 x i64> [[TMP0]], i32 6
; SINK-GATHER-NEXT:    [[TMP51:%.*]] = getelementptr inbounds i32, ptr [[A]], i64 [[TMP50]]
; SINK-GATHER-NEXT:    [[TMP52:%.*]] = load i32, ptr [[TMP51]], align 4
; SINK-GATHER-NEXT:    [[TMP53:%.*]] = udiv i32 [[TMP52]], [[X]]
; SINK-GATHER-NEXT:    [[TMP54:%.*]] = insertelement <8 x i32> [[TMP48]], i32 [[TMP53]], i32 6
; SINK-GATHER-NEXT:    br label [[PRED_UDIV_CONTINUE12]]
; SINK-GATHER:       pred.udiv.continue12:
; SINK-GATHER-NEXT:    [[TMP55:%.*]] = phi i32 [ poison, [[PRED_UDIV_CONTINUE10]] ], [ [[TMP52]], [[PRED_UDIV_IF11]] ]
; SINK-GATHER-NEXT:    [[TMP56:%.*]] = phi <8 x i32> [ [[TMP48]], [[PRED_UDIV_CONTINUE10]] ], [ [[TMP54]], [[PRED_UDIV_IF11]] ]
; SINK-GATHER-NEXT:    [[TMP57:%.*]] = extractelement <8 x i1> [[BROADCAST_SPLAT]], i32 7
; SINK-GATHER-NEXT:    br i1 [[TMP57]], label [[PRED_UDIV_IF13:%.*]], label [[PRED_UDIV_CONTINUE14]]
; SINK-GATHER:       pred.udiv.if13:
; SINK-GATHER-NEXT:    [[TMP58:%.*]] = extractelement <8 x i64> [[TMP0]], i32 7
; SINK-GATHER-NEXT:    [[TMP59:%.*]] = getelementptr inbounds i32, ptr [[A]], i64 [[TMP58]]
; SINK-GATHER-NEXT:    [[TMP60:%.*]] = load i32, ptr [[TMP59]], align 4
; SINK-GATHER-NEXT:    [[TMP61:%.*]] = udiv i32 [[TMP60]], [[X]]
; SINK-GATHER-NEXT:    [[TMP62:%.*]] = insertelement <8 x i32> [[TMP56]], i32 [[TMP61]], i32 7
; SINK-GATHER-NEXT:    br label [[PRED_UDIV_CONTINUE14]]
; SINK-GATHER:       pred.udiv.continue14:
; SINK-GATHER-NEXT:    [[TMP63:%.*]] = phi i32 [ poison, [[PRED_UDIV_CONTINUE12]] ], [ [[TMP60]], [[PRED_UDIV_IF13]] ]
; SINK-GATHER-NEXT:    [[TMP64:%.*]] = phi <8 x i32> [ [[TMP56]], [[PRED_UDIV_CONTINUE12]] ], [ [[TMP62]], [[PRED_UDIV_IF13]] ]
; SINK-GATHER-NEXT:    [[TMP65:%.*]] = xor <8 x i1> [[BROADCAST_SPLAT]], <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>
; SINK-GATHER-NEXT:    [[PREDPHI:%.*]] = select <8 x i1> [[BROADCAST_SPLAT]], <8 x i32> [[TMP64]], <8 x i32> [[BROADCAST_SPLAT16]]
; SINK-GATHER-NEXT:    [[TMP66]] = add <8 x i32> [[VEC_PHI]], [[PREDPHI]]
; SINK-GATHER-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 8
; SINK-GATHER-NEXT:    [[VEC_IND_NEXT]] = add <8 x i64> [[VEC_IND]], <i64 8, i64 8, i64 8, i64 8, i64 8, i64 8, i64 8, i64 8>
; SINK-GATHER-NEXT:    [[TMP67:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; SINK-GATHER-NEXT:    br i1 [[TMP67]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP4:![0-9]+]]
; SINK-GATHER:       middle.block:
; SINK-GATHER-NEXT:    [[TMP68:%.*]] = call i32 @llvm.vector.reduce.add.v8i32(<8 x i32> [[TMP66]])
; SINK-GATHER-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[SMAX]], [[N_VEC]]
; SINK-GATHER-NEXT:    br i1 [[CMP_N]], label [[FOR_END:%.*]], label [[SCALAR_PH]]
; SINK-GATHER:       scalar.ph:
; SINK-GATHER-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC]], [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; SINK-GATHER-NEXT:    [[BC_MERGE_RDX:%.*]] = phi i32 [ 0, [[ENTRY]] ], [ [[TMP68]], [[MIDDLE_BLOCK]] ]
; SINK-GATHER-NEXT:    br label [[FOR_BODY:%.*]]
; SINK-GATHER:       for.body:
; SINK-GATHER-NEXT:    [[I:%.*]] = phi i64 [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ], [ [[I_NEXT:%.*]], [[FOR_INC:%.*]] ]
; SINK-GATHER-NEXT:    [[R:%.*]] = phi i32 [ [[BC_MERGE_RDX]], [[SCALAR_PH]] ], [ [[T6:%.*]], [[FOR_INC]] ]
; SINK-GATHER-NEXT:    [[I7:%.*]] = mul i64 [[I]], 777
; SINK-GATHER-NEXT:    br i1 [[C]], label [[IF_THEN:%.*]], label [[FOR_INC]]
; SINK-GATHER:       if.then:
; SINK-GATHER-NEXT:    [[T0:%.*]] = getelementptr inbounds i32, ptr [[A]], i64 [[I7]]
; SINK-GATHER-NEXT:    [[T2:%.*]] = load i32, ptr [[T0]], align 4
; SINK-GATHER-NEXT:    [[T4:%.*]] = udiv i32 [[T2]], [[X]]
; SINK-GATHER-NEXT:    br label [[FOR_INC]]
; SINK-GATHER:       for.inc:
; SINK-GATHER-NEXT:    [[T5:%.*]] = phi i32 [ [[X]], [[FOR_BODY]] ], [ [[T4]], [[IF_THEN]] ]
; SINK-GATHER-NEXT:    [[T6]] = add i32 [[R]], [[T5]]
; SINK-GATHER-NEXT:    [[I_NEXT]] = add nuw nsw i64 [[I]], 1
; SINK-GATHER-NEXT:    [[COND:%.*]] = icmp slt i64 [[I_NEXT]], [[N]]
; SINK-GATHER-NEXT:    br i1 [[COND]], label [[FOR_BODY]], label [[FOR_END]], !llvm.loop [[LOOP5:![0-9]+]]
; SINK-GATHER:       for.end:
; SINK-GATHER-NEXT:    [[T7:%.*]] = phi i32 [ [[T6]], [[FOR_INC]] ], [ [[TMP68]], [[MIDDLE_BLOCK]] ]
; SINK-GATHER-NEXT:    ret i32 [[T7]]
;
entry:
  br label %for.body

for.body:
  %i = phi i64 [ 0, %entry ], [ %i.next, %for.inc ]
  %r = phi i32 [ 0, %entry ], [ %t6, %for.inc ]
  %i7 = mul i64 %i, 777
  br i1 %c, label %if.then, label %for.inc

if.then:
  %t0 = getelementptr inbounds i32, ptr %a, i64 %i7
  %t2 = load i32, ptr %t0, align 4
  %t4 = udiv i32 %t2, %x
  br label %for.inc

for.inc:
  %t5 = phi i32 [ %x, %for.body ], [ %t4, %if.then]
  %t6 = add i32 %r, %t5
  %i.next = add nuw nsw i64 %i, 1
  %cond = icmp slt i64 %i.next, %n
  br i1 %cond, label %for.body, label %for.end

for.end:
  %t7 = phi i32 [ %t6, %for.inc ]
  ret i32 %t7
}