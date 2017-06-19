cDisplayBuffer	EQU		30H		;在显示的内容在30H-37H
cDisplayBit		EQU		3CH		;当前显示的位
cCount			EQU		40H		;40H和41H为转过的圈数


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
		MOV		cDisplayBuffer+8,#0
		MOV		cDisplayBuffer+9,#0
		MOV		cDisplayBuffer+10,#0
		MOV		cDisplayBuffer+11,#0

		SETB	EX0
		SETB	EA
		SETB	IT0
M1:
		LCALL	Display
		MOV		R0,#0
		DJNZ	R0,$
		nop
		LCALL	DISTANCE
		LCALL 	DistanceToDisplay
		LCALL 	FEE
		LCALL 	FeeTodisplay
		LCALL 	SPEED
		LCALL 	SpeedTodisplAy

//		JB		P3.7,M2
//		LCALL	Count
//		SJMP	M3
//M2:
//		LCALL	DecCount
//M3:

		SJMP	M1

INT0PROC:;计数转过的圈数	  	
		JNB 		P3.7,M2
		LCALL	Count
M2:

		RETI


Count:
		INC		41H
		MOV		A,41H
		JNZ		CC1
		INC		40H
CC1:		
		RET

DISTANCE:
		MOV 	A,41H;40H和41H存储圈数
		MOV 	B,#0B7H
		MUL 	AB
		MOV 	45H,A;里程数存入44H和45H
		MOV 	4AH,B
		MOV 	B,#0B7H
		MOV 	A,40H
		MUL 	AB
		ADD 	A,4AH
		MOV 	44H,A

FEE:
		MOV 	A,45H
		MOV 	A,45H;44H和45H存储里程数
		MOV 	B,#01AH
		MUL 	AB
		MOV 	49H,A;将费用存入48H和49H
		MOV 	4AH,B
		MOV 	B,#1AH
		MOV 	A,44H
		MUL 	AB
		ADD 	A,4AH
		MOV 	48H,A
		MOV 	A,49H;把费用加上起步价8块
		ADDC 	A,#20H
		MOV 	49H,A
		MOV 	A,48H
		ADDC	A,#03H
		MOV 	48H,A
SPEED:
		MOV 	A,@R0
		MOV 	B,#0B7H
		MUL 	AB
		MOV 	45H,A
		MOV 	4AH,B
		MOV 	B,#0B7H
		MOV 	A,@R1
		MUL 	AB
		ADD 	A,4AH
		MOV 	44H,A
DistanceToDisplay:
		MOV		42H,40H
		MOV		43H,41H
		MOV		R0,#42H		;42H为高位字节，43H为低位字节
		MOV		R1,#50H		;结果为6位BCD码
		LCALL	BinDec		;只取用四位BCD码
		
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

FeeToDisplay:

		MOV		42H,48H
		MOV		43H,49H
		MOV		R0,#42H		;42H为高位字节，43H为低位字节
		MOV		R1,#50H		;结果为6位BCD码
		LCALL	BinDec
		
		MOV		A,51H
		ANL		A,#0FH
		MOV		cDisplayBuffer+1,A
		MOV		A,51H
		SWAP	A
		ANL		A,#0FH
		MOV		cDisplayBuffer+0,A
		
		MOV		A,52H
		ANL		A,#0FH
		MOV		cDisplayBuffer+3,A
		MOV		A,52H
		SWAP	A
		ANL		A,#0FH
		MOV		cDisplayBuffer+2,A
		RET	 	

SpeedToDisplay:

		MOV		42H,46H
		MOV		43H,47H
		MOV		R0,#42H		;42H为高位字节，43H为低位字节
		MOV		R1,#50H		;结果为6位BCD码
		LCALL	BinDec
		
		MOV		A,51H
		ANL		A,#0FH
		MOV		cDisplayBuffer+9,A
		MOV		A,51H
		SWAP	A
		ANL		A,#0FH
		MOV		cDisplayBuffer+8,A
		
		MOV		A,52H
		ANL		A,#0FH
		MOV		cDisplayBuffer+11,A
		MOV		A,52H
		SWAP	A
		ANL		A,#0FH
		MOV		cDisplayBuffer+10,A
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
	MOV 	A,cDisplayBit
	CJNE	A,#12,EN
	ANL	cDisplayBit,#16
EN:	ret
	
		END