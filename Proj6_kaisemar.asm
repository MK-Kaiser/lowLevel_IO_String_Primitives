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
	MOV					ESI,			EDX					; backup prompt for next loop
	MOV					EDX,			EDI					; restore values after prompt
	CALL				ReadString
	ADD					EDX,			4
ENDM

mDisplayString			MACRO				string
	MOV					EDX,				string
	CALL				WriteString
ENDM

COUNT	=	10

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
values					SDWORD			12						DUP(0)

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
	MOV						EDX,			OFFSET			programTitle
	CALL					WriteString
	CALL					CrLf

	MOV						EDX,			OFFSET			instructions
	CALL					WriteString


	MOV						ECX,			COUNT
	PUSH					OFFSET			values			
	PUSH					OFFSET			prompt

_getValues:
	CALL					ReadVal
	PUSH					EDX
	PUSH					ESI
	LOOP					_getValues


	MOV						ECX,			COUNT
	MOV						EDX,			OFFSET			values
_print:
	PUSH					EDX
	CALL					WriteVal
	LOOP					_print

	Invoke					ExitProcess,0	; exit to operating system
main ENDP

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
	MOV						EDI,			[EBP+12]			; values
	mGetString				

	MOV					ESP,			EBP
	POP					EBP
	RET					

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
