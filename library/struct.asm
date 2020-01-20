
BITS 64

SECTION .text
	GLOBAL	update_member

update_member:
	PUSH	RBP			;initiate the stack frame
	MOV		RBP, RSP
	
	PUSH	RAX			;save the temporary registers
	PUSH	RBX
	
	MOV		RAX, [RBP+24]
	MOV		RBX, [RBP+16]
	MOV		[RAX], RBX
	MOV		[RBP+24], RAX
	
	POP		RBX			;restore the registers
	POP		RAX
	
	MOV		RSP, RBP	;dismantle the stackframe
	POP		RBP
	RET		16			;return two parameters 
