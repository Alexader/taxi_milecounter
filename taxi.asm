;双字节中断计数
cDisplayBuffer	EQU		30H		;在显示的内容在30H-37H
cDisplayBit		EQU		38H		;当前显示的位
cCount			EQU		40H
       	ORG   	0000H
		LJMP	Main
		ORG		0003H
		LJMP	INT0PROC
Main:
		MOV		R2,#1

		MOV		cDisplayBuffer,#0
		MOV		cDisplayBuffer+1,#0
		MOV		cDisplayBuffer+2,#0
		MOV		cDisplayBuffer+3,#0

		MOV		cDisplayBuffer+4,#0
		MOV		cDisplayBuffer+5,#0
		MOV		cDisplayBuffer+6,#0
		MOV		cDisplayBuffer+7,#0

		MOV		40H,#0
		MOV		R4,#0
		SETB	EX0
		SETB	EA
		SETB	IT0
M1:
		LCALL	Display
		MOV		R0,#0
		DJNZ	R0,$
		


		SJMP	M1

INT0PROC:
		JB		P3.7,M2
		LCALL	Count
		SJMP	M3
M2:
		LCALL	DecCount
M3:

		RETI


Count:
		INC		41H
		MOV		A,41H
		JNZ		CC1
		INC		40H
CC1:		
		LCALL	ToDisplay
		RET


DecCount:
		DEC		41H
		MOV		A,41H
		CJNE	A,#255,DC1
		DEC		40H
DC1:		
		LCALL	ToDisplay
		RET

ToDisplay:

		MOV		42H,40H
		MOV		43H,41H
		MOV		R0,#42H		;42H为高位字节，43H为低位字节
		MOV		R1,#50H		;结果为6位BCD码
		LCALL	BinDec
		
		MOV		A,50H
		MOV		cDisplayBuffer+3,A
		MOV		A,51H
		ANL		A,#0FH
		MOV		cDisplayBuffer+5,A
		MOV		A,51H
		SWAP	A
		ANL		A,#0FH
		MOV		cDisplayBuffer+4,A
		
		MOV		A,52H
		ANL		A,#0FH
		MOV		cDisplayBuffer+7,A
		MOV		A,52H
		SWAP	A
		ANL		A,#0FH
		MOV		cDisplayBuffer+6,A

		
		RET
	 	


;---------------BinDec---------------------------
; 把双字节的十六进制数转换为BCD码
; 输入:  R0 - 十六进制数的高字节地址
;        R1 - 转换后BCD码的高位地址
BinDec:
		CLR             A
        MOV             @R1,A
		INC             R1
		MOV             @R1,A
		INC             R1
		MOV             @R1,A
		PUSH            7
		MOV             R7,#16
BD1:
		CLR             C
		INC             R0
		MOV             A,@R0
		RLC             A
		MOV             @R0,A
		DEC             R0
		MOV             A,@R0
		RLC             A
		MOV             @R0,A

		PUSH            1
		MOV             A,@R1
		ADDC            A,@R1
		DA              A
		MOV             @R1,A
		DEC             R1
		MOV             A,@R1
		ADDC            A,@R1
		DA              A
		MOV             @R1,A
		DEC             R1
		MOV             A,@R1
		ADDC            A,@R1
		DA              A
		MOV             @R1,A
		POP             1

		DJNZ            R7,BD1
		POP             7

		RET
;---------------BinDec---------------------------


DispTable:	DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH
Display:
	MOV   A,cDisplayBit
	MOV	P2,A
	MOV	DPTR,#DispTable
	MOV   A,#cDisplayBuffer
	ADD  	A,cDisplayBit
	MOV	R0,A
	MOV   A,@R0
	MOVC	A,@A+DPTR
	MOV	P1,A
	INC	cDisplayBit
	ANL	cDisplayBit,#7
	 ret
	



		END