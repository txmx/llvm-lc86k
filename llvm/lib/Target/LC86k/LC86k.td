include "llvm/Target/Target.td"

def LC86kInstrInfo : InstrInfo;
def LC86kAsmParser : AsmParser;

def LC86k : Target {
	let InstructionSet = LC86kInstrInfo;
	let AssemblyParsers = [LC86kAsmParser];
}

include "LC86kRegisterInfo.td"
include "LC86kCallingConv.td"
include "LC86kInstrInfo.td"
