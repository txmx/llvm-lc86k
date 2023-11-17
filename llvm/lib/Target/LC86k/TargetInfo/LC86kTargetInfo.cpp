#include "LC86kTargetInfo.h"
#include <llvm/MC/TargetRegistry.h>

using namespace llvm;

Target &llvm::getTheLC86kTarget() {
	static Target theLC86kTarget;

	return theLC86kTarget;
}

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeLC86kTargetInfo() {
	RegisterTarget<Triple::lc86k, false> LC86k(
		llvm::getTheLC86kTarget(), 
		"lc86k", 
		"Sanyo LC86k", 
		"VMU");
}
