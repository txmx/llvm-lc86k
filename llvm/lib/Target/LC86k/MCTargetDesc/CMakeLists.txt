add_llvm_component_library(LLVMLC86kDesc
	LC86kMCTargetDesc.cpp

	LINK_COMPONENTS
	MC
	LC86kInfo
	Support
	TargetParser

	ADD_TO_COMPONENT
	LC86k
)

add_dependencies(LLVMLC86kDesc LC86kCommonTableGen)
