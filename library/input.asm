BITS 64

%INCLUDE "handling.mac"

SECTION .text
	GLOBAL input

clear_buffer:
	PUSH	RBP			;initiate the stack frame
	MOV		RBP, RSP
	
	PUSH	RAX			;save RAX
	
	MOV		RAX, [RBP+24]	;move the buffer into RAX
	MOV		RCX, [RBP+16]	;move the buffer length into RCX
	
	__input_clear_buffer_first:	;loop to clear the buffer
		MOV	BYTE[RAX], 0	;move 0 into a byte of RAX
		INC	RAX				;increment RAX
	LOOP	__input_clear_buffer_first	;loop
	
	MOV		QWORD [RBP+24], 0		;delete the arguments
	MOV		QWORD [RBP+16], 0
	
	POP		RAX			;restore RAX
	
	MOV		RSP, RBP	;dismantle the stack frame
	POP		RBP
	RET		16

input:
	PUSH	RBP
	MOV		RBP, RSP
	
	;save the registers
	pushall
	
	PUSH	QWORD [RBP+24]	;push the buffer
	PUSH	QWORD [RBP+16]	;push the buffer's length	
	CALL	clear_buffer	;clear the buffer
	
	__input_forcevalue:
	
	MOV		RAX, 0		;move the SYS_READ call into RAX
	MOV		RSI, [RBP+24]	;move the clean buffer into RSI
	MOV		RDX, [RBP+16]	;move the buffer size into RDX
	MOV		RDI, RAX		;move RAX into destination
	SYSCALL				;POKE
	
	CMP		RAX, 1		;if RAX only has newline in it
	JE		__input_forcevalue	;redo the input
	
	
	MOV		RSI, [RBP+24]	;move the buffer into RSI
	__input_find_newline:
	CMP		BYTE [RSI], 0ah	;compare a byte of RSI to newline
	JE		__input_delete_newline	;delete the newline character
	INC		RSI				;add 1 to RSI
	JMP		__input_find_newline	;loop
	__input_delete_newline:
	MOV		BYTE [RSI], 0	;replace the newline value with 0

	
	MOV		QWORD [RBP+24], 0		;delete the arguments
	MOV		QWORD [RBP+16], 0
	
	popall
	
	MOV		RSP, RBP
	POP		RBP
	RET		16
	
