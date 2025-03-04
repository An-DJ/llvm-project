; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -loop-reduce -S | FileCheck %s

target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n64-S128"
target triple = "riscv64"


define void @icmp_zero(i64 %N, ptr %p) {
; CHECK-LABEL: @icmp_zero(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[LSR_IV:%.*]] = phi i64 [ [[LSR_IV_NEXT:%.*]], [[VECTOR_BODY]] ], [ [[N:%.*]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    store i64 0, ptr [[P:%.*]], align 8
; CHECK-NEXT:    [[LSR_IV_NEXT]] = add i64 [[LSR_IV]], -2
; CHECK-NEXT:    [[DONE:%.*]] = icmp eq i64 [[LSR_IV_NEXT]], 0
; CHECK-NEXT:    br i1 [[DONE]], label [[EXIT:%.*]], label [[VECTOR_BODY]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %vector.body

vector.body:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %vector.body ]
  store i64 0, ptr %p
  %iv.next = add i64 %iv, 2
  %done = icmp eq i64 %iv.next, %N
  br i1 %done, label %exit, label %vector.body

exit:
  ret void
}

define void @icmp_zero_urem_nonzero_con(i64 %N, ptr %p) {
; CHECK-LABEL: @icmp_zero_urem_nonzero_con(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[UREM:%.*]] = urem i64 [[N:%.*]], 16
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[LSR_IV:%.*]] = phi i64 [ [[LSR_IV_NEXT:%.*]], [[VECTOR_BODY]] ], [ [[UREM]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    store i64 0, ptr [[P:%.*]], align 8
; CHECK-NEXT:    [[LSR_IV_NEXT]] = add i64 [[LSR_IV]], -2
; CHECK-NEXT:    [[DONE:%.*]] = icmp eq i64 [[LSR_IV_NEXT]], 0
; CHECK-NEXT:    br i1 [[DONE]], label [[EXIT:%.*]], label [[VECTOR_BODY]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  %urem = urem i64 %N, 16
  br label %vector.body

vector.body:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %vector.body ]
  store i64 0, ptr %p
  %iv.next = add i64 %iv, 2
  %done = icmp eq i64 %iv.next, %urem
  br i1 %done, label %exit, label %vector.body

exit:
  ret void
}

; FIXME: We could handle this case even though we don't know %M.  The
; faulting instruction is already outside the loop!
define void @icmp_zero_urem_invariant(i64 %N, i64 %M, ptr %p) {
; CHECK-LABEL: @icmp_zero_urem_invariant(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[UREM:%.*]] = urem i64 [[N:%.*]], [[M:%.*]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    store i64 0, ptr [[P:%.*]], align 8
; CHECK-NEXT:    [[IV_NEXT]] = add i64 [[IV]], 2
; CHECK-NEXT:    [[DONE:%.*]] = icmp eq i64 [[IV_NEXT]], [[UREM]]
; CHECK-NEXT:    br i1 [[DONE]], label [[EXIT:%.*]], label [[VECTOR_BODY]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  %urem = urem i64 %N, %M
  br label %vector.body

vector.body:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %vector.body ]
  store i64 0, ptr %p
  %iv.next = add i64 %iv, 2
  %done = icmp eq i64 %iv.next, %urem
  br i1 %done, label %exit, label %vector.body

exit:
  ret void
}

; Negative test - We can not hoist because we don't know value of %M.
define void @icmp_zero_urem_nohoist(i64 %N, i64 %M, ptr %p) {
; CHECK-LABEL: @icmp_zero_urem_nohoist(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    store i64 0, ptr [[P:%.*]], align 8
; CHECK-NEXT:    [[IV_NEXT]] = add i64 [[IV]], 2
; CHECK-NEXT:    [[UREM:%.*]] = urem i64 [[N:%.*]], [[M:%.*]]
; CHECK-NEXT:    [[DONE:%.*]] = icmp eq i64 [[IV_NEXT]], [[UREM]]
; CHECK-NEXT:    br i1 [[DONE]], label [[EXIT:%.*]], label [[VECTOR_BODY]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %vector.body

vector.body:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %vector.body ]
  store i64 0, ptr %p
  %iv.next = add i64 %iv, 2
  %urem = urem i64 %N, %M
  %done = icmp eq i64 %iv.next, %urem
  br i1 %done, label %exit, label %vector.body

exit:
  ret void
}

define void @icmp_zero_urem_nonzero(i64 %N, i64 %M, ptr %p) {
; CHECK-LABEL: @icmp_zero_urem_nonzero(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[NONZERO:%.*]] = add nuw i64 [[M:%.*]], 1
; CHECK-NEXT:    [[UREM:%.*]] = urem i64 [[N:%.*]], [[NONZERO]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[LSR_IV:%.*]] = phi i64 [ [[LSR_IV_NEXT:%.*]], [[VECTOR_BODY]] ], [ [[UREM]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    store i64 0, ptr [[P:%.*]], align 8
; CHECK-NEXT:    [[LSR_IV_NEXT]] = add i64 [[LSR_IV]], -2
; CHECK-NEXT:    [[DONE:%.*]] = icmp eq i64 [[LSR_IV_NEXT]], 0
; CHECK-NEXT:    br i1 [[DONE]], label [[EXIT:%.*]], label [[VECTOR_BODY]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  %nonzero = add nuw i64 %M, 1
  %urem = urem i64 %N, %nonzero
  br label %vector.body

vector.body:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %vector.body ]
  store i64 0, ptr %p
  %iv.next = add i64 %iv, 2
  %done = icmp eq i64 %iv.next, %urem
  br i1 %done, label %exit, label %vector.body

exit:
  ret void
}

define void @icmp_zero_urem_vscale(i64 %N, ptr %p) {
; CHECK-LABEL: @icmp_zero_urem_vscale(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[VSCALE:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[UREM:%.*]] = urem i64 [[N:%.*]], [[VSCALE]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[LSR_IV:%.*]] = phi i64 [ [[LSR_IV_NEXT:%.*]], [[VECTOR_BODY]] ], [ [[UREM]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    store i64 0, ptr [[P:%.*]], align 8
; CHECK-NEXT:    [[LSR_IV_NEXT]] = add i64 [[LSR_IV]], -2
; CHECK-NEXT:    [[DONE:%.*]] = icmp eq i64 [[LSR_IV_NEXT]], 0
; CHECK-NEXT:    br i1 [[DONE]], label [[EXIT:%.*]], label [[VECTOR_BODY]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  %vscale = call i64 @llvm.vscale.i64()
  %urem = urem i64 %N, %vscale
  br label %vector.body

vector.body:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %vector.body ]
  store i64 0, ptr %p
  %iv.next = add i64 %iv, 2
  %done = icmp eq i64 %iv.next, %urem
  br i1 %done, label %exit, label %vector.body

exit:
  ret void
}

define void @icmp_zero_urem_vscale_mul8(i64 %N, ptr %p) {
; CHECK-LABEL: @icmp_zero_urem_vscale_mul8(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[VSCALE:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[MUL:%.*]] = mul nuw nsw i64 [[VSCALE]], 8
; CHECK-NEXT:    [[UREM:%.*]] = urem i64 [[N:%.*]], [[MUL]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    store i64 0, ptr [[P:%.*]], align 8
; CHECK-NEXT:    [[IV_NEXT]] = add i64 [[IV]], 2
; CHECK-NEXT:    [[DONE:%.*]] = icmp eq i64 [[IV_NEXT]], [[UREM]]
; CHECK-NEXT:    br i1 [[DONE]], label [[EXIT:%.*]], label [[VECTOR_BODY]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  %vscale = call i64 @llvm.vscale.i64()
  %mul = mul nuw nsw i64 %vscale, 8
  %urem = urem i64 %N, %mul
  br label %vector.body

vector.body:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %vector.body ]
  store i64 0, ptr %p
  %iv.next = add i64 %iv, 2
  %done = icmp eq i64 %iv.next, %urem
  br i1 %done, label %exit, label %vector.body

exit:
  ret void
}


define void @icmp_zero_urem_vscale_mul64(i64 %N, ptr %p) {
; CHECK-LABEL: @icmp_zero_urem_vscale_mul64(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[VSCALE:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[MUL:%.*]] = mul nuw nsw i64 [[VSCALE]], 64
; CHECK-NEXT:    [[UREM:%.*]] = urem i64 [[N:%.*]], [[MUL]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    store i64 0, ptr [[P:%.*]], align 8
; CHECK-NEXT:    [[IV_NEXT]] = add i64 [[IV]], 2
; CHECK-NEXT:    [[DONE:%.*]] = icmp eq i64 [[IV_NEXT]], [[UREM]]
; CHECK-NEXT:    br i1 [[DONE]], label [[EXIT:%.*]], label [[VECTOR_BODY]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  %vscale = call i64 @llvm.vscale.i64()
  %mul = mul nuw nsw i64 %vscale, 64
  %urem = urem i64 %N, %mul
  br label %vector.body

vector.body:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %vector.body ]
  store i64 0, ptr %p
  %iv.next = add i64 %iv, 2
  %done = icmp eq i64 %iv.next, %urem
  br i1 %done, label %exit, label %vector.body

exit:
  ret void
}

define void @icmp_zero_urem_vscale_shl3(i64 %N, ptr %p) {
; CHECK-LABEL: @icmp_zero_urem_vscale_shl3(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[VSCALE:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[SHL:%.*]] = shl i64 [[VSCALE]], 3
; CHECK-NEXT:    [[UREM:%.*]] = urem i64 [[N:%.*]], [[SHL]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    store i64 0, ptr [[P:%.*]], align 8
; CHECK-NEXT:    [[IV_NEXT]] = add i64 [[IV]], 2
; CHECK-NEXT:    [[DONE:%.*]] = icmp eq i64 [[IV_NEXT]], [[UREM]]
; CHECK-NEXT:    br i1 [[DONE]], label [[EXIT:%.*]], label [[VECTOR_BODY]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  %vscale = call i64 @llvm.vscale.i64()
  %shl = shl i64 %vscale, 3
  %urem = urem i64 %N, %shl
  br label %vector.body

vector.body:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %vector.body ]
  store i64 0, ptr %p
  %iv.next = add i64 %iv, 2
  %done = icmp eq i64 %iv.next, %urem
  br i1 %done, label %exit, label %vector.body

exit:
  ret void
}

define void @icmp_zero_urem_vscale_shl6(i64 %N, ptr %p) {
; CHECK-LABEL: @icmp_zero_urem_vscale_shl6(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[VSCALE:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[SHL:%.*]] = shl i64 [[VSCALE]], 6
; CHECK-NEXT:    [[UREM:%.*]] = urem i64 [[N:%.*]], [[SHL]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    store i64 0, ptr [[P:%.*]], align 8
; CHECK-NEXT:    [[IV_NEXT]] = add i64 [[IV]], 2
; CHECK-NEXT:    [[DONE:%.*]] = icmp eq i64 [[IV_NEXT]], [[UREM]]
; CHECK-NEXT:    br i1 [[DONE]], label [[EXIT:%.*]], label [[VECTOR_BODY]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  %vscale = call i64 @llvm.vscale.i64()
  %shl = shl i64 %vscale, 6
  %urem = urem i64 %N, %shl
  br label %vector.body

vector.body:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %vector.body ]
  store i64 0, ptr %p
  %iv.next = add i64 %iv, 2
  %done = icmp eq i64 %iv.next, %urem
  br i1 %done, label %exit, label %vector.body

exit:
  ret void
}

declare i64 @llvm.vscale.i64()
