TITLE Project 6     (Proj6_kaisemar.asm)

COMMENT !
Author: Mark Kaiser
Last Modified: 23 November 2021
OSU email address: kaisemar@oregonstate.edu
Course number/section:   CS271 Section 400
Project Number: 6            
Due Date: 5 December 2021
Description: ...
!

INCLUDE Irvine32.inc

; two macros: mGetString and mDisplayString
mGetString				MACRO
	CALL				WriteString
	MOV					EBX,			EDX					; backup prompt for next loop
	MOV					EDX,			ESI					; restore values after prompt
	INC					ECX
	CALL				ReadString
	DEC					ECX

	MOV					ESI,			EDX
	LODSB
	CMP					EAX,				LO
	JB					_invalid
	CMP					EAX,				HI
	JA					_invalid
	;SUB					EAX,				LO
	ADD					EDX,			4
	JMP					_continue

_invalid:
	MOV						ESI,			EDX
	MOV						EDX,			EDI
	CALL					WriteString
	MOV						EDX,			EBX
	JMP						_tryAgain

ENDM

mDisplayString			MACRO				string
	MOV					EDX,				string
	CALL				WriteString
ENDM

COUNT	=	10
LO		=   30h
HI		=	39h

.data

programTitle			BYTE			"Project 6: Custom low level input/ouput procedures.",13,10
						BYTE			"Author: Mark Kaiser",13,10,0
instructions			BYTE			"Please provide 10 signed integers.",13,10
						BYTE			"Each less than the 32 bit limit.",13,10
						BYTE			"Once all 10 valid signed integers have been input the following will be displayed: ",13,10
						BYTE			"the list of integers, their sum, and their average.",13,10,0
prompt					BYTE			"Enter a signed integer: ",0
error					BYTE			"Error: The supplied signed integer is too large, please try again.",13,10,0
list					BYTE			"You supplied the following numbers: ",13,10,0
sum						BYTE			"The sum is: ",13,10,0
average					BYTE			"The rounded average is: ",13,10,0
goodbye					BYTE			"Thanks for stopping by, good bye.",13,10,0
values					BYTE			10 DUP(?),0

.code
main PROC
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; NAME: main
; This prodcedure calls all other procedures to include stack parameter setup.
; Preconditions: N/A
; Receives: N/A
; Returns: N/A
; Usage of PUSH, OFFSET, CALL, CMP, JConds referenced from: CS271 Instruction Reference.
; Usage of CreateOutputFile, Randomize, OpenInputFile, and ReadFromFile referenced from: CS271 Irvine Reference.
; Formatting in accordance with: CS271 Style Guide.
; Modifies Stack to push parameters, comparison of EDI to check sort progress and ECX for looping over sortList.
; CreateOutputFile places filehandle address in EAX, EDX is loaded with randArray offset and ECX with ARRAYSIZE*4 for use with ReadFromFile procedure.
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	PUSH					OFFSET			programTitle
	PUSH					OFFSET			instructions
	CALL					introduction


	MOV						ECX,			COUNT
	PUSH					OFFSET			error
	PUSH					OFFSET			values			
	PUSH					OFFSET			prompt

_getValues:
	CALL					ReadVal
	PUSH					EDI
	PUSH					EDX
	PUSH					EBX
	LOOP					_getValues

	MOV						ECX,			COUNT
	MOV						EDX,			OFFSET			values
_print:
	PUSH					EDX
	CALL					WriteVal
	LOOP					_print

	Invoke					ExitProcess,0	; exit to operating system
main ENDP


introduction PROC
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; NAME: introduction
; This prodcedure handles output of program, programmer introduction and extra credit title.
; Preconditions: Called by main procedure.
; Receives: Two parameters that are offsets address to where string is in memory.
; Returns: N/A
; Usage of CALL WriteString referenced from: CS271 Irvine Procedure Reference.
; Formatting in accordance with: CS271 Style Guide.
; Modifies EDX to load memory address of string to be printed on standard output. EBP and ESP registers used to preserve stack frame and restore return address to stack.
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	PUSH		EBP							; preserve EBP
	MOV			EBP,			ESP			; static stack-frame pointer
	MOV			EDX,			[EBP+12]	; grabs introduction message from stack
	CALL		WriteString
	CALL		CrLf
	MOV			EDX,			[EBP+8]		; grabs description message from stack
	CALL		WriteString
	CALL		CrLf
	MOV			ESP,			EBP			; restore ESP
	POP			EBP							; restore old EBP
	CALL		CrLf
	RET			8

introduction ENDP


ReadVal PROC
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; NAME: main
; This prodcedure calls all other procedures to include stack parameter setup.
; Preconditions: N/A
; Receives: N/A
; Returns: N/A
; Usage of PUSH, OFFSET, CALL, CMP, JConds referenced from: CS271 Instruction Reference.
; Usage of CreateOutputFile, Randomize, OpenInputFile, and ReadFromFile referenced from: CS271 Irvine Reference.
; Formatting in accordance with: CS271 Style Guide.
; Modifies Stack to push parameters, comparison of EDI to check sort progress and ECX for looping over sortList.
; CreateOutputFile places filehandle address in EAX, EDX is loaded with randArray offset and ECX with ARRAYSIZE*4 for use with ReadFromFile procedure.
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	PUSH					EBP
	MOV						EBP,			ESP
	MOV						EDX,			[EBP+8]				; prompt
	MOV						ESI,			[EBP+12]			; values
	MOV						EDI,			[EBP+16]			; error

_tryAgain:
	mGetString				

_continue:
	MOV					ESP,			EBP
	POP					EBP
	RET					12
	


ReadVal ENDP


WriteVal PROC
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; NAME: main
; This prodcedure calls all other procedures to include stack parameter setup.
; Preconditions: N/A
; Receives: N/A
; Returns: N/A
; Usage of PUSH, OFFSET, CALL, CMP, JConds referenced from: CS271 Instruction Reference.
; Usage of CreateOutputFile, Randomize, OpenInputFile, and ReadFromFile referenced from: CS271 Irvine Reference.
; Formatting in accordance with: CS271 Style Guide.
; Modifies Stack to push parameters, comparison of EDI to check sort progress and ECX for looping over sortList.
; CreateOutputFile places filehandle address in EAX, EDX is loaded with randArray offset and ECX with ARRAYSIZE*4 for use with ReadFromFile procedure.
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	PUSH					EBP
	MOV						EBP,			ESP
	MOV						EDX,			[EBP+8]				; values

	mDisplayString			EDX
	ADD						EDX,			4
	PUSH					EDX
	MOV						ESP,			EBP
	POP						EBP
	RET


WriteVal ENDP

END main
