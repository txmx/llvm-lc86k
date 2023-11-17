def CC_LC86k : CallingConv<[
	CCIfType<[i8], CCAssignToReg<[(sequence "Cell%u", 0, 225)]>>,
]>;
