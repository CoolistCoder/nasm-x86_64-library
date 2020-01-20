
BITS 64

SECTION .data
	SYS_WRITE	equ 1

SECTION .text
	GLOBAL strlen
	GLOBAL print
	GLOBAL printful
	GLOBAL newline
	GLOBAL printchar
	GLOBAL printnum
	GLOBAL printint
	GLOBAL printsint

strlen:
	PUSH	RBP			;save base pointer
	MOV		RBP, RSP	;create stack frame
	
	PUSH	RSI			;save RSI
	
	MOV		RSI, [RBP+16]	;move the message into RSI
	XOR		RAX, RAX		;set RAX to 0
	
	__strlen_count:			;accumulation loop
		CMP	BYTE [RSI], 0h	;compare a character of the message to 0
		JE	__strlen_count_break	;jump if the byte is 0
		
		INC		RAX				;add 1 to RAX
		INC		RSI				;go to next character in message
		JMP		__strlen_count	;jump to the top of the loop
	__strlen_count_break:		;break the loop
	
	MOV		QWORD [RBP+16], 0			;delete the data stored in the stack
	
	POP		RSI					;restore RSI
	
	MOV		RSP, RBP	;dismantle stack frame
	POP		RBP			;restore base pointer
	RET	8
	
print:
	PUSH	RBP			;save base pointer
	MOV		RBP, RSP	;create stack frame
	
	;push all temporary registers
	PUSH	RSI
	PUSH	RDX
	PUSH	RDI
	PUSH	RAX

	MOV		RSI, [RBP+24]	;move message into RSI
	MOV		RDX, [RBP+16]	;move message length into RDX
	MOV		RAX, SYS_WRITE			;SYSTEM WRITE
	MOV		RDI, RAX		;destination to RAX
	SYSCALL					;POKE
	
	MOV		QWORD [RBP+24], 0		;delete the message
	MOV		QWORD [RBP+16], 0		;delete the length of the message

	;pop all temporary registers
	POP		RAX
	POP		RDI
	POP		RDX
	POP		RSI
	
	MOV		RSP, RBP	;dismantle stack frame
	POP		RBP			;restore base pointer
	RET 16
	
printful:
	PUSH	RBP			;save base pointer
	MOV		RBP, RSP	;create stack frame
	
	PUSH	QWORD [RBP+16]	;push the message
	CALL	strlen		;get the length of the string
	PUSH	QWORD [RBP+16]	;push the message again
	PUSH	RAX			;push the string's length
	CALL	print		;print the message
	
	MOV		QWORD [RBP+16], 0	;delete argument

	MOV		RSP, RBP	;dismantle stack frame
	POP		RBP			;restore base pointer
	ret 8

printchar:
	PUSH	RBP			;save base pointer
	MOV		RBP, RSP	;create stack frame
	
	;push all temporary registers
	PUSH	RSI
	PUSH	RDX
	PUSH	RDI
	PUSH	RAX

	LEA		RSI, [RBP+16]	;move message into RSI
	MOV		RDX, 1	;move message length into RDX
	MOV		RAX, SYS_WRITE			;SYSTEM WRITE
	MOV		RDI, RAX		;destination to RAX
	SYSCALL					;POKE
	
	MOV		QWORD [RBP+16], 0	;delete argument
	
	;pop all temporary registers
	POP		RAX
	POP		RDI
	POP		RDX
	POP		RSI
	
	MOV		RSP, RBP	;dismantle stack frame
	POP		RBP			;restore base pointer
	ret 	8
	
newline:
	PUSH	RBP			;save base pointer
	MOV		RBP, RSP	;create stack frame
	SUB		RSP, 8		;two local variables
	MOV		[RBP], BYTE 0ah	;new line
	
	;push all temporary registers
	PUSH	RSI
	PUSH	RDX
	PUSH	RDI
	PUSH	RAX
	
	LEA		RSI, [RBP]	;move newline into RSI
	MOV		RDX, 1	;move message length into RDX
	MOV		RAX, SYS_WRITE			;SYSTEM WRITE
	MOV		RDI, RAX		;destination to RAX
	SYSCALL					;POKE
	
	;pop all temporary registers
	POP		RAX
	POP		RDI
	POP		RDX
	POP		RSI
	
	MOV		RSP, RBP	;dismantle stack frame
	POP		RBP			;restore base pointer
	ret 	

printnum:
	PUSH	RBP			;save base pointer
	MOV		RBP, RSP	;create stack frame
	
	;push all temporary registers
	PUSH	RSI
	PUSH	RDX
	PUSH	RDI	
	PUSH	RCX
	PUSH	RAX
	
	MOV		RCX, [RBP+16]	;get the original value of the pushed number
	ADD		QWORD [RBP+16], 30h	;test with single digit
	LEA		RSI, [RBP+16]	;move newline into RSI
	MOV		RDX, 1	;move message length into RDX
	MOV		RAX, SYS_WRITE			;SYSTEM WRITE
	MOV		RDI, RAX		;destination to RAX
	SYSCALL					;POKE
	
	MOV		QWORD [RBP+16], 0	;delete argument
	
	;pop all temporary registers
	POP		RAX
	POP		RCX
	POP		RDI
	POP		RDX
	POP		RSI

	MOV		RSP, RBP	;dismantle stack frame
	POP		RBP			;restore base pointer
	ret 8
	
printint:
	PUSH	RBP			;save base pointer
	MOV		RBP, RSP	;create stack frame
	
	PUSH	RBX			;save registers
	PUSH	RAX
	PUSH	RCX
	PUSH	RDX
	
	CMP		QWORD [RBP+16], 0	;determine if the value is 0
	JNE		__printint_normal	;if it isn't ignore this part
	PUSH	0					;if it is
	CALL	printnum			;print out the 0
	JMP		__printPrintint_loop_ignore	;and ignore the function
	__printint_normal:			;continue on as normal
	
	MOV		RBX, 10			;value to divide by
	MOV		RAX, [RBP+16]	;move the number into RAX
	
	XOR		RCX, RCX		;this is going to be the incrementor
	
	__printint_loop:		;loop to print numbers
	CMP		RAX, 0
	JE		__printint_loop_break	;break
	
	DIV		RBX						;divide RAX by 10
	INC		RCX						;increment RCX
	PUSH	RDX						;push the mod value to stack
	XOR		RDX, RDX				;clear out RDX
	JMP		__printint_loop			;jump to the top of the loop
	__printint_loop_break:
	
	CMP		RCX, 0					;if there was nothing pushed
	JE		__printPrintint_loop_ignore	;prevent the loop from occuring
	
	__printPrintint_loop:			;the loop where printing occurs
		
		CALL	printnum
		LOOP	__printPrintint_loop	;loop back to printloop
		
	MOV		QWORD [RBP+16], 0	;delete argument
	
	__printPrintint_loop_ignore:
	
	POP		RDX
	POP		RCX
	POP		RAX
	POP		RBX			;restore registers

	MOV		RSP, RBP	;dismantle stack frame
	POP		RBP			;restore base pointer
	ret 8
	
printsint:
	PUSH	RBP			;save base pointer
	MOV		RBP, RSP	;create stack frame
	
	PUSH	RBX			;save registers
	PUSH	RAX
	PUSH	RCX
	PUSH	RDX
	
	CMP		QWORD [RBP+16], 0	;determine if the value is 0
	JNE		__printsint_normal	;if it isn't, ignore this part
	PUSH	0					;if it is
	CALL	printnum			;print 0
	JMP		__printPrintint_loop_ignore	;jump to the end of the function
	__printsint_normal:			;break
	
	MOV		RBX, 10			;value to divide by
	MOV		RAX, [RBP+16]	;move the number into RAX
	
	;need to modify RAX to make the number legible
	CMP		RAX, 0
	JGE	__printsint_neg_ignore
	
	PUSH	"-"				;push the negative sign
	CALL	printchar		;print the character
	NOT		RAX				;invert the bits
	INC		RAX				;add 1 to simulate two's compliment
	
	__printsint_neg_ignore:	;ignore the negation if not negative
	
	XOR		RCX, RCX		;this is going to be the incrementor
	
	__printsint_loop:		;loop to print numbers
	CMP		RAX, 0
	JE		__printsint_loop_break	;break
	
	DIV		RBX						;divide RAX by 10
	INC		RCX						;increment RCX
	PUSH	RDX						;push the mod value to stack
	XOR		RDX, RDX				;clear out RDX
	JMP		__printsint_loop			;jump to the top of the loop
	__printsint_loop_break:
	
	CMP		RCX, 0					;if there was nothing pushed
	JE		__printPrintsint_loop_ignore	;prevent the loop from occuring
	
	__printPrintsint_loop:			;the loop where printing occurs
		
		CALL	printnum
		LOOP	__printPrintsint_loop	;loop back to printloop
	
	MOV		QWORD [RBP+16], 0	;delete argument
	
	__printPrintsint_loop_ignore:
	
	
	
	POP		RDX
	POP		RCX
	POP		RAX
	POP		RBX			;restore registers

	MOV		RSP, RBP	;dismantle stack frame
	POP		RBP			;restore base pointer
	ret 8
