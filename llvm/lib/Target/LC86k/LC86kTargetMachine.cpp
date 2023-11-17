#include "LC86kTargetMachine.h"
#include "TargetInfo/LC86kTargetInfo.h"
#include <llvm/MC/TargetRegistry.h>
#include <optional>

using namespace llvm;

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeLC86kTarget() {
	RegisterTargetMachine<LC86kTargetMachine> LC86kMachine(getTheLC86kTarget());
}

static StringRef LC86kDataLayout = "e-p:8:8";

LC86kTargetMachine::LC86kTargetMachine(
	const Target& T,
	const Triple& TT,
	StringRef CPU,
	StringRef FS,
	const TargetOptions& Options,
	std::optional<Reloc::Model> RM,
	std::optional<CodeModel::Model> CM,
	CodeGenOptLevel Level,
	bool JIT)
	: LLVMTargetMachine(T, LC86kDataLayout, TT, CPU, FS, Options, RM.value_or(Reloc::Static), CM.value_or(CodeModel::Small), Level)
{
	initAsmInfo();
}
