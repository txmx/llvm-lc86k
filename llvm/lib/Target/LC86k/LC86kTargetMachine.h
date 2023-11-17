#ifndef LLVM_LC86K_TARGET_MACHINE_H
#define LLVM_LC86K_TARGET_MACHINE_H

#include <llvm/IR/DataLayout.h>
#include <llvm/Target/TargetMachine.h>
#include <optional>

namespace llvm {
	class LC86kTargetMachine : public LLVMTargetMachine {
		//std::unique_ptr<TargetLoweringObjectFile> tlof;
		
		public:
	    LC86kTargetMachine(
			const Target &T, 
			const Triple &TT, 
			StringRef CPU, 
			StringRef FS,
			const TargetOptions &Options,
			std::optional<Reloc::Model> RM,
			std::optional<CodeModel::Model> CM,
			CodeGenOptLevel Level,
			bool JIT);

		//TargetLoweringObjectFile *getObjFileLowering() const override;
	};
}

#endif
