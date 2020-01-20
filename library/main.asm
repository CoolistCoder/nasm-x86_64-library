%INCLUDE "handling.mac"
%INCLUDE "print.inc"
%INCLUDE "struct.inc"
%INCLUDE "convert.inc"
%INCLUDE "input.inc"
%INCLUDE "handling.inc"

struc	mystruct
	.xpos	resq	1
	.ypos	resq	1
endstruc

;data segment
SECTION .data
	nameprompt	db	"Please insert your name >> ", 0h
	quantprompt db	"Please give me a numbered value: ", 0h
	mymsg	db	"The value you inserted is: ", 0h
	myend	db	"!", 0h
	myname	db	0
	
	mynum	db "-154"
	
	quitval	db	"quit"
	
	errmsg db "value is not valid", 0ah, 0h

;reserved memory segment
SECTION .bss
	structure	resq	2
	altstruct	resq	2
	buffer		resb	1
	

;program
SECTION .text
GLOBAL	_start
_start:
	NOP
		pushall
		

		
		myloop:
		push	quantprompt	;print the message
		call	printful
		
		push	buffer	;input
		push	500
		call	input
		
		push	rbx
		push	buffer
		call	strint
		
		cmp		rbx, 0
		jl		inputerror
		
		pop		rbx
		push	rax
		call	printsint
		call	newline
		
		popall
	NOP
call	exit
	

inputerror:
	pop		rbx
	push	errmsg
	call	printful
	jmp		myloop



