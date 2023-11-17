add_llvm_component_library(
	LLVMLC86kInfo LC86kTargetInfo.cpp

	LINK_COMPONENTS
	MC
	Support

	ADD_TO_COMPONENT
	LC86k)