BITS 64

%INCLUDE "print.inc"

SECTION .text
	GLOBAL strint

strint:
	PUSH	RBP
	MOV		RBP, RSP
	
	;push all temporary registers

	PUSH	RCX
	PUSH	RDX
	PUSH	RSI
	
	XOR		RBX, RBX		;reset RBX
	MOV		RSI, [RBP+16]	;move the number string into RSI
	PUSH	RSI				;get the length of the string
	CALL	strlen
	MOV		RCX, RAX		;move the strlen value into RCX
	XOR		RBX, RBX		;RBX will perform operations on the bytes
	XOR		RDX, RDX		;RDX will hold multiples of 10
	MOV		RDX, 1			;start RDX with 1 and multiply by 10 each time
	XOR		RAX, RAX		;RAX will be the result
	
	__strint_loop:
		MOVZX	RBX, BYTE [RSI + RCX -1]	;move the character of RSI into RAX
		
		CMP		RBX, "-"		;if the value turns out negative
		JE		__strint_neg	;handle it
		CMP		RBX, 2Fh		;if RBX is less than the desired range
		JLE		__strint_cancel	;finish
		CMP		RBX, 3Ah		;if RBX is greater than the desired range
		JGE		__strint_cancel ;finish

		SUB		RBX, 30h		;take the ascii value to an integer
		PUSH	RAX				;make sure RAX is saved
		MOV		RAX, RBX		;MOV the value into RAX
		PUSH	RDX				;save RDX
		MUL		RDX				;x^10
		POP		RDX				;restore RDX
		MOV		RBX, RAX		;MOV the value back into RBX
		POP		RAX				;restore RAX
		ADD		RAX, RBX		;add the value in RBX to RAX
		PUSH	RAX				;save RAX again
		PUSH	RBX				;save RBX to store 10
		MOV		RBX, 10			;move 10 into RBX
		MOV		RAX, RDX		;move RDX into RAX
		MUL		RBX				;I need to mul by 10
		MOV		RDX, RAX		;move the new value back into RAX
		POP		RBX				;pop RBX back
		POP		RAX				;pop RAX back
	LOOP	__strint_loop	;loop 
	JMP		__strint_finish
	__strint_neg:			;the number was negative
	NEG		RAX				;turn RAX negative
	JMP		__strint_finish	;jump to finish
	__strint_cancel:
	MOV		RBX, -1			;failure core
	MOV		RAX, 0			;cancel out value if 
	__strint_finish:		;function is finished
	
	MOV		QWORD [RBP+16], 0	;delete argument
	
	;restore temporary registers
	POP		RSI
	POP		RDX
	POP		RCX
	
	MOV		RSP, RBP
	POP		RBP
	ret		8
