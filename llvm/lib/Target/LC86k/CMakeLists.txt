add_llvm_component_group(LC86k)

set(LLVM_TARGET_DEFINITIONS LC86k.td)

tablegen(LLVM LC86kRegisterInfo.inc --gen-register-info)
tablegen(LLVM LC86kInstrInfo.inc --gen-instr-info)

add_public_tablegen_target(LC86kCommonTableGen)

add_llvm_target(LC86kCodeGen
	LC86kTargetMachine.cpp
	
	LINK_COMPONENTS
	LC86kInfo
	AsmPrinter
	CodeGen
	CodeGenTypes
	Core
	MC
	SelectionDAG
	Support
	Target

	ADD_TO_COMPONENT
	LC86k
)

add_subdirectory(TargetInfo)
add_subdirectory(MCTargetDesc)
