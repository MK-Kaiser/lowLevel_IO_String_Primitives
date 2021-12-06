TITLE Project 6     (Proj6_kaisemar.asm)

COMMENT !
Author: Mark Kaiser
Last Modified: 4 December 2021
OSU email address: kaisemar@oregonstate.edu
Course number/section:   CS271 Section 400
Project Number: 6            
Due Date: 5 December 2021
Description: This program takes in an array of string characters and stores them as integers via ReadVal and mGetString.
getSum and getAverage then perform calculations on the stored integers and then WriteVal is called to convert these integers back to string format.
The stringify procedure helps WriteVal by handling the conversion portion of this process. Finally mDisplayString is called everytime a string is ready to be printed.
!

INCLUDE Irvine32.inc

; two macros: mGetString and mDisplayString
mGetString				MACRO			buffer, size
	PUSH				ECX
	PUSH				EDX
	MOV					EDX,			buffer
	MOV					ECX,			size
	CALL				ReadString
	POP					EDX
	POP					ECX
ENDM

mDisplayString			MACRO				string
	MOV					EDX,				string
	CALL				WriteString
ENDM

COUNT	=	3
LO		=   30h
HI		=	39h

.data

programTitle			BYTE			"Project 6: Custom low level input/ouput procedures.",13,10
						BYTE			"Author: Mark Kaiser",13,10,0
instructions			BYTE			"Please provide 10 signed integers.",13,10
						BYTE			"Each less than the 32 bit limit.",13,10
						BYTE			"Once all 10 valid signed integers have been input the following will be displayed: ",13,10
						BYTE			"the list of integers, the sum, and the rounded average.",13,10,0
prompt					BYTE			"Enter a signed integer: ",0
error					BYTE			"Error: The supplied signed integer is too large, please try again.",13,10,0
listTitle				BYTE			"You supplied the following numbers: ",0
sumTitle				BYTE			"The sum is: ",0
averageTitle			BYTE			"The rounded average is: ",0
goodbye					BYTE			"Thanks for stopping by, good bye.",13,10,0
delimiter				BYTE			", ",0
input					SDWORD			30	DUP(0)
bufferList				SDWORD			30	DUP(0)
bufferSum				SDWORD			30	DUP(0)
bufferAverage			SDWORD			30	DUP(0)
sum						SDWORD			0
average					SDWORD			0
buffer					SDWORD			30	DUP(?)




.code
main PROC
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; NAME: main
; This prodcedure calls all other procedures to include stack parameter setup.
; Preconditions: N/A
; Receives: N/A
; Returns: N/A
; Usage of PUSH, OFFSET, CALL, CMP, MOV, INVOKE, LOOP, JConds referenced from: CS271 Instruction Reference.
; Formatting in accordance with: CS271 Style Guide.
; Modifies Stack to push parameters, calls all other procedures to include: Intro, ReadVal and WriteVal.
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	PUSH					OFFSET			programTitle
	PUSH					OFFSET			instructions
	CALL					Intro
	CALL					CrLf

	MOV						ECX,			COUNT
	MOV						ESI,			OFFSET			input
	MOV						EDI,			OFFSET			bufferList
_getValues:
	PUSH					EDI
	PUSH					SIZEOF			input
	PUSH					ECX								; resumes with previous ECX count
	PUSH					OFFSET			error			; use same error string each time
	PUSH					ESI								; resume with previous buffer offset
	PUSH					OFFSET			prompt			; use same prompt string each time
	CALL					ReadVal
	LOOP					_getValues
	CALL					CrLf

	PUSH					OFFSET			sum
	PUSH					OFFSET			bufferList
	CALL					getSum

	PUSH					OFFSET			sum
	PUSH					OFFSET			average
	CALL					getAverage

	PUSH					OFFSET			bufferAverage
	PUSH					OFFSET			bufferSum
	PUSH					OFFSET			delimiter
	PUSH					OFFSET			buffer
	PUSH					OFFSET			average
	PUSH					OFFSET			sum
	PUSH					OFFSET			bufferList
	PUSH					OFFSET			sumTitle
	PUSH					OFFSET			averageTitle
	PUSH					OFFSET			listTitle
	CALL					WriteVal
	CALL					CrLf


	PUSH					OFFSET			goodbye
	CALL					sayBye

	Invoke					ExitProcess,0					; exit to operating system
main ENDP

Intro PROC
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; NAME: Intro
; This prodcedure calls MACRO mDisplayString and outputs the programTitle and instructions
; Preconditions: N/A
; Receives: Memory address of programTitle and instructions from the stack.
; Returns: Outputs the strings stored at the referenced addresses.
; Usage of PUSH, MOV, POP referenced from: CS271 Instruction Reference.
; Formatting in accordance with: CS271 Style Guide.
; Modifies Stack to push parameters, sends to MACRO mDisplayString.
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	PUSH					EBP
	MOV						EBP,			ESP
	mDisplayString			[EBP+12]					; display programTitle
	CALL					CrLf
	mDisplayString			[EBP+8]						; instructions
	MOV						ESP,			EBP
	POP						EBP
	RET						8


Intro ENDP

ReadVal PROC
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; NAME: ReadVal
; This prodcedure calls all other procedures to include stack parameter setup.
; Preconditions: N/A
; Receives: prompt, input buffer offset, error offset, COUNT constant, and list buffer offset.
; Returns: Outputs user prompt and stores user input as strings in input buffer and LODSB transfers as integers to list buffer.
; Usage of PUSH, POP, OFFSET, INC, DEC, CMP, JConds referenced from: CS271 Instruction Reference.
; Formatting in accordance with: CS271 Style Guide.
; Prompts user for input by passing prompt to mDisplayString MACRO and then the input buffer and buffer size are passed to mGetString MACRO.
; LODSB is utilized to move a copy into the AL register, where the input value is compared against the upper and lower limits.
; If a supplied character is outside of these limits a jump to _invalid occurs where ECX is restored and mDisplayString is called to display the warning.
; If a supplied character is valid, the value in AL is reduced to its integer equivalent value and stored at the current edi address as a value.
; The EDI address is incremented and continues additional times depending on how many digits the supplied character is.
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	PUSH				EBP
	MOV					EBP,			ESP
	MOV					EDX,			[EBP+8]				; prompt
	MOV					ESI,			[EBP+12]			; input buffer
	MOV					EBX,			[EBP+16]			; error
	MOV					ECX,			[EBP+20]			; COUNT
	MOV					EDI,			[EBP+28]			; list buffer
	mDisplayString		[EBP+8]								; display programTitle
	mGetString			[EBP+12],		[EBP+24]

	PUSH				EBP
	PUSH				ECX
	MOV					ECX,			EAX
	LODSB
	MOV					EDX,			EAX

_positiveCheck:
	CMP					EDX,			2Bh
	JNE					_negativeCheck
	MOV					EBP,			1
	LODSB
	DEC					ECX
	MOV					EDX,			EAX

_negativeCheck:
	CMP					EDX,			2Dh
	JNE					_noSign
	MOV					EBP,			-1
	LODSB
	DEC					ECX
	MOV					EDX,			EAX

_noSign:
	MOV					EBP,			0
	CMP					EDX,			LO
	JB					_invalid
	CMP					EDX,			HI
	JA					_invalid

	MOV					EBX,			10
_convert:
	MOV					DL,			AL
	CMP					DL,			LO
	JB					_exit
	CMP					DL,			HI
	JA					_exit
	SUB					EDX,			LO


	PUSH				EDX
	MOV					EAX,			EBP
	IMUL				EBX
	POP					EDX
	JO					_invalid						; check for overflow
	MOV					EBP,			EAX
	ADD					EBP,			EDX				
	JO					_invalid						; check for overflow
	DEC					ECX
	LODSB
	CMP					ECX,			0
	JA					_convert
	POP					ECX
	MOV					[EDI],			EBP
	POP					EBP
	ADD					EDI,			4
	JMP					_exit

_invalid:
	POP					ECX
	INC					ECX								; input didnt count
	POP					EBP
	mDisplayString		[EBP+16]

_exit:
	MOV					ESP,			EBP
	POP					EBP
	RET					28
	
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
	mDisplayString			[EBP+8]							; display prompt
	MOV						ESI,			[EBP+20]		; list
	MOV						ECX,			COUNT
	MOV						EDI,			[EBP+32]		; buffer
_outputString:
	PUSH					ECX
	ADD						EDI,				4
	PUSH					EDI								; buffer
	PUSH					3								; size
	PUSH					ESI
	CALL					stringify
	POP						ECX
	MOV						EDX,			EDI
	INC						EDX
	mDisplayString			EDX
	CMP						ECX,			1
	JE						_skipDelim
	PUSH					EDX
	MOV						EDX,			[EBP+36]
	mDisplayString			EDX								; delimiter
_skipDelim:
	POP						EDX
	ADD						ESI,				4
	LOOP					_outputString
	CALL					CrLf


	mDisplayString			[EBP+16]						; sum prompt
	MOV						ESI,			[EBP+24]		; sum
	MOV						ECX,			3
	MOV						EDI,			[EBP+40]		; bufferSum
	PUSH					EDI
	PUSH					ECX
	PUSH					ESI
	CALL					stringify
	INC						EDI
	mDisplayString			EDI								; sum result
	CALL					CrLf


	mDisplayString			[EBP+12]						; average prompt
	MOV						ESI,			[EBP+28]		; average
	MOV						ECX,			3
	MOV						EDI,			[EBP+44]		; bufferAverage
	PUSH					EDI
	PUSH					ECX
	PUSH					ESI
	CALL					stringify
	INC						EDI
	mDisplayString			EDI						; average result
	CALL					CrLf


	MOV						ESP,			EBP
	POP						EBP
	RET						40


WriteVal ENDP


getSum PROC
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; NAME: getSum
; This prodcedure calls MACRO mDisplayString and outputs the programTitle and instructions
; Preconditions: N/A
; Receives: Memory address of programTitle and instructions from the stack.
; Returns: Outputs the strings stored at the referenced addresses.
; Usage of PUSH, MOV, POP referenced from: CS271 Instruction Reference.
; Formatting in accordance with: CS271 Style Guide.
; Modifies Stack to push parameters, sends to MACRO mDisplayString.
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	PUSH					EBP
	MOV						EBP,			ESP
	MOV						EBX,			0
	MOV						ESI,			[EBP+8]						; list of integers
	MOV						EDI,			[EBP+12]					; sum memory offset
	MOV						ECX,			10

_calcSum:
	LODSD
	ADD						EBX,			EAX
	LOOP					_calcSum
	MOV						[EDI],			EBX
	MOV						ESP,			EBP
	POP						EBP
	RET						8


getSum ENDP


getAverage PROC
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; NAME: getAverage
; This prodcedure calls MACRO mDisplayString and outputs the programTitle and instructions
; Preconditions: N/A
; Receives: Memory address of programTitle and instructions from the stack.
; Returns: Outputs the strings stored at the referenced addresses.
; Usage of PUSH, MOV, POP referenced from: CS271 Instruction Reference.
; Formatting in accordance with: CS271 Style Guide.
; Modifies Stack to push parameters, sends to MACRO mDisplayString.
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	PUSH					EBP
	MOV						EBP,			ESP
	MOV						EBX,			0
	MOV						EDI,			[EBP+8]					; average memory offset
	MOV						ESI,			[EBP+12]				; sum memory offset
	CDQ
	MOV						EAX,			[ESI]
	MOV						EBX,			10
	IDIV					EBX
	CMP						EDX,			5
	JGE						_increment

_exit:
	MOV						[EDI],			EAX						; store value at average memory address
	MOV						ESP,			EBP
	POP						EBP
	RET						8

_increment:
	INC						EAX
	JMP						_exit

getAverage ENDP


stringify PROC
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; NAME: stringify
; This prodcedure calls MACRO mDisplayString and outputs the programTitle and instructions
; Preconditions: N/A
; Receives: an integer
; Returns: the integer in string form
; Usage of PUSH, MOV, POP referenced from: CS271 Instruction Reference.
; Formatting in accordance with: CS271 Style Guide.
; Modifies Stack to push parameters, sends to MACRO mDisplayString.
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	PUSH					EBP
	MOV						EBP,			ESP
	MOV						ESI,			[EBP+8]						; integer
	MOV						ECX,			[EBP+12]					; gets size/length of integer
	MOV						EDI,			[EBP+16]
	MOV						EAX,			[ESI]
	MOV						EBX,			10
	CMP						EAX,			0

_incrementPrep:
	INC						EDI
	LOOP					_incrementPrep								; increments in preparation for backward fill of ASCII representation of number.
	JG						_divide
	NEG						EAX											; flip to positive for absolute value

_divide:
	MOV						EDX,			0							; clears for remainder after division
	DIV						EBX
	XCHG					EAX,			EDX							; swap remainder and quotient
	ADD						AL,				'0'
	MOV						[EDI],			AL							; store character representation of number
	DEC						EDI											; moves down memory address
	XCHG					EAX,			EDX							; swap remainder/quotient back
	INC						ECX
	CMP						EAX,			0
	JNZ						_divide										; check if more division required

	MOV						ESP,			EBP
	POP						EBP
	RET						12


stringify ENDP


sayBye PROC
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; NAME: sayBye
; This prodcedure calls MACRO mDisplayString and outputs the programTitle and instructions
; Preconditions: N/A
; Receives: Memory address of programTitle and instructions from the stack.
; Returns: Outputs the strings stored at the referenced addresses.
; Usage of PUSH, MOV, POP referenced from: CS271 Instruction Reference.
; Formatting in accordance with: CS271 Style Guide.
; Modifies Stack to push parameters, sends to MACRO mDisplayString.
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	PUSH					EBP
	MOV						EBP,			ESP
	mDisplayString			[EBP+8]						; goodbye
	MOV						ESP,			EBP
	POP						EBP
	RET						4


sayBye ENDP


END main
