class LC86kReg<bits<9> addr, string name> : Register<name> {
	let HWEncoding{8-0} = addr{8-0};
	let Namespace = "LC86k";
}

def ACC : LC86kReg<0x100, "acc">;
def B   : LC86kReg<0x102, "b">;
def C   : LC86kReg<0x103, "c">;

def Accumulator : RegisterClass<"LC86k", [i8], 8, (add ACC)>;
