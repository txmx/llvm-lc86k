// RUN: %clang_cc1 -fprofile-instrument=llvm -disable-llvm-passes \
// RUN:   -emit-llvm -o - %s | FileCheck %s
// RUN: %clang_cc1 -fprofile-instrument=csllvm -disable-llvm-passes \
// RUN:   -emit-llvm -o - %s | FileCheck %s
// RUN: %clang_cc1 -fprofile-instrument=clang -disable-llvm-passes \
// RUN:   -emit-llvm -o - %s | FileCheck %s
// RUN: %clang_cc1 -coverage-data-file=/dev/null -disable-llvm-passes \
// RUN:   -emit-llvm -o - %s | FileCheck %s
int g(int);

void __attribute__((no_profile_instrument_function)) no_instr(void) {
// CHECK: define {{.*}}void @no_instr() [[ATTR:#[0-9]+]]
}

void instr(void) {
// CHECK: define {{.*}}void @instr() [[ATTR2:#[0-9]+]]
}
// CHECK: attributes [[ATTR]] = {{.*}} noprofile
// CHECK: attributes [[ATTR2]] = {
// CHECK-NOT: noprofile
// CHECK: }
