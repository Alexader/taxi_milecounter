; ���⳵�Ʒ���

;����ȫ�ֱ��������ͨ���� 
cDispBuffer		EQU		10H		;һ��12����Ļ��һ��12�ֽ� 10H - 1BH
cDisplayBit		EQU		1CH	    ;������ʾ����Ļ	  1CH

cOneSecond		EQU		1DH		;ʱ���жϴﵽ1��ָʾλ
cOneMSecond     EQU		1EH	   	;ʱ���жϴﵽ1����ָʾλ

IntOneSecond	EQU		1FH		;��¼һ�����ⲿ�жϴ��������ֽ�
TotalInto		EQU		20H		;�ۼ������ⲿ�жϴ�����˫�ֽ� 20H-21H

Kilometer		EQU		23H		;�ܹ�����(��λ��ַ)�����ֽ�	 23H-25H
KilometerBcd			EQU		28H		;�ܹ�����(��λ��ַ)�����ֽ�	 27H-30H

Speed			EQU		32H		;�ٶ�(��λ��ַ)�����ֽ�		32H-34H
SpeedBcd		EQU		36H		;�ٶ�bcd��(��λ��ַ)�����ֽ�  36H-39H

Buffer			EQU		40H		;���ֽڳ���������

PriceBuffer1		EQU		50H		;�ܷ�����(��λ��ַ)�����ֽ�	 50H-52H
PriceBuffer1Bcd			EQU		53H		;�ܹ�����(��λ��ַ)�����ֽ�	 53H-56H


		ORG		0000H
		LJMP		Initialization    ;��ѭ��

		ORG		0003H
		LJMP		Intro ;�ⲿ�ж�0

		ORG		000BH
		LJMP		TimerInto ;�ڲ��������ж�0

		ORG		30H

;��ʼ�����������ͨ����
Initialization:	
		MOV		SP,#60H;���ö�ջָ��
		MOV		cDisplayBit,#0	
		MOV		cDispBuffer,#0
		MOV		cDispBuffer+1,#8
		MOV		cDispBuffer+2,#0
		MOV		cDispBuffer+3,#0
		MOV		cDispBuffer+4,#0
		MOV		cDispBuffer+5,#0
		MOV		cDispBuffer+6,#0
		MOV		cDispBuffer+7,#0
		MOV		cDispBuffer+8,#0
		MOV		cDispBuffer+9,#0
		MOV		cDispBuffer+10,#0
		MOV		cDispBuffer+11,#0

		MOV	 	cOneSecond,#0 
		MOV 	cOneMSecond,#0 ;ʱ���ж�ָʾ��

		MOV		IntOneSecond,#0
		MOV		TotalInto,#0
		MOV		TotalInto+1,#0 ;�����ⲿ�ж��ۼ���

		
		;�жϳ�ʼ������ʱ������ֵ�����ú��ⲿ�жϣ����ͨ����			
		;���ö�ʱ��
		MOV		TMOD,#01H
		SETB	TR0
		SETB	ET0
		MOV		TH0,#0F8H	 												;0x0FA2A
		MOV		TL0,#0CDH
	   	
		;�����ⲿ�ж�
		SETB	EX0
		SETB	EA
		SETB	IT0	

;��ʼ�����������ͨ����

	;	MOV cMotorCount,#56H
	;	MOV cMotorCount+1,#5H
MainLoop:;��ѭ��
		;ÿ��1���Ӽ���һ���ٶ�.
		;���ϼ��㲢��ʾ���
	

		JNB		P3.7,Stop;�ȴ�P3.7����1������ť������
		SETB	EX0	;�����
		SETB	IT0	;�����
		SJMP	MainLoop ;ѭ��
Stop:  ;��ť�����¾�ֹͣ
		CLR		EX0	   ;�ر��ж�ϵͳ
		CLR		IT0		;�ĳɵ�ƽ����		
		SJMP	MainLoop ;ѭ��

;�ⲿ�ж���ת�����ͨ����
;�ⲿ�ж�����ģ���ٶȣ��жϵ�ʱ��ִ�м򵥼�һ
Intro:	
		PUSH PSW
		PUSH ACC
	  	CLR 	C  ;��֤CλΪ0
		MOV		A,TotalInto   ;���жϴ���cMotorCount��˫�ֽ�����1
		ADDC		A,#1		   ;���жϴ���cMotorCount��˫�ֽ�����1
		MOV		TotalInto,A  ;���жϴ���cMotorCount��˫�ֽ�����1
		MOV		A,TotalInto+1;���жϴ���cMotorCount��˫�ֽ�����1
		ADDC	A,#0		   ;���жϴ���cMotorCount��˫�ֽ�����1
		MOV		TotalInto+1,A;���жϴ���cMotorCount��˫�ֽ�����1
		INC		IntOneSecond ;����һ���ڵ��жϴ���
		POP ACC
		POP PSW 
		RETI
;�ⲿ�ж���ת �����ͨ���� 
  
;ʱ���ж���ת�����ͨ����
;����1ms�Ķ�ʱ�жϣ����ϵ�����ʾ��ɨ�����
;��һ��������ÿ�ж�һ�μ�1������10������bt10ms��־
TimerInto:
		LCALL	Display

		INC		cOneMSecond
		MOV 	TH0,#0F8H
		MOV		TL0,#0CDH ;��ʱ1ms��F8CD
		MOV		A,cOneMSecond
		CJNE 	A,#10,EndTimerInto;���ж�֮��û�е�10����ֱ�ӷ���

		LCALL	CalculateDistance  ;����Ѿ���10�������һ�����

		MOV 	cOneMSecond,#0;��ʱ�жϹ�0������10��
		INC 	cOneSecond;ÿ10ms ������һ����ָʾ��
		MOV		A,cOneSecond;�����ŵ�A�Ĵ��������ж���ת
		CJNE 	A,#100,EndTimerInto ;һ�����1000ms
		MOV 	cOneSecond,#0;��ָʾ����0

		LCALL 	MyCalSpeed;ÿ�����һ���ٶ�

EndTimerInto:

		RETI	;ʱ���жϷ���
;ʱ���ж���ת�����ͨ����


;��ʾ������	�����ͨ����
;P1.7ΪС����   
;�����ɨ������ڶ�ʱ�ж������
DispTable:	DB		3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH;��Ȼʹ��ԭ����10�����ֵľ������ʾ����
Display:
		MOV 	A,cDisplayBit
		MOV		P2,A
		MOV		DPTR,#DispTable
		MOV   	A,#cDispBuffer
		ADD  	A,cDisplayBit
		MOV		R0,A
		MOV 	A,@R0
		MOVC	A,@A+DPTR
		MOV		P1,A

		;������Щλ��Ҫ����С����
		MOV		A,cDisplayBit;ȡ��Ŀǰ��ʾ����Ļ
		CJNE	A,#1,Next1
		SETB	P1.7 ;1������С����
Next1:	;5����Ļ����С����
		CJNE	A,#5,Next2
		SETB	P1.7
Next2:	;7������С����
		CJNE	A,#10,Next3
		SETB	P1.7 ;10����ʾ����С����
Next3:
		INC		cDisplayBit	;��ʾ���Ƶ���һ��
		MOV 	A,cDisplayBit
		CJNE	A,#12,EndDisp
		MOV 	cDisplayBit,#0;�������൱�ڽ���ʾ��������0-12֮�䣬�൱��ȡģ����mod 12
EndDisp:		
		RET
;��ʾ������	�����ͨ����


;���㲢��ʾ����̣����ͨ����
CalculateDistance:
		MOV		A,TotalInto ;ȡ�ⲿ�ж�����
		MOV		B,#0B7H;�ܳ���1.83������������183��������
		;����˫�ֽ��뵥�ֽڣ�0B7H����˵Ĳ���
		MUL		AB;
		MOV		Kilometer+2,A
		MOV		Kilometer+1,B
		MOV		A,TotalInto+1
		MOV		B,#0B7H
		MUL		AB
		ADD		A,Kilometer+1
		MOV		Kilometer+1,A
		MOV		A,#0
		ADDC	A,B
		MOV		Kilometer,A
		;��ɵ��ֽ���˫�ֽڳ˷��������Kilometer�������ֽ���	

		;������װ��λ����������Ĳ���
		;16���Ƶ��������100
		MOV Buffer,#64H;��ֵ100��ʮ������
		MOV Buffer+1,#0
		MOV Buffer+2,#0
		MOV Buffer+3,#0
		MOV	Buffer+4,Kilometer
		MOV	Buffer+5,Kilometer+1
		MOV	Buffer+6,Kilometer+2
		MOV Buffer+7,#0
		MOV	R0,#Buffer+1
		MOV	R1,#Buffer+2
		MOV	R6,#2
		MOV	R7,#6	 
		LCALL	DivBytes ;���ö��ֽڳ�������						 
		MOV	Kilometer,Buffer+6
		MOV	Kilometer+1,Buffer+7 ;���õ��ĳ�100�Ժ����������·Ż�������Ĵ洢�ռ�
		
		;���濪ʼ������ת��10����
		;��16������10���ƹ�����ڴ�λ�÷ŵ�R0��R1����ת10���Ƴ���Ĳ���׼��	
		MOV		R0,#Kilometer
		MOV		R1,#KilometerBcd
		LCALL	BinDec;����10����ת�����򣬵õ����10������
		;���¹����ǽ�ת���õ�10��������������ֽڰ��˵���ʾ��������
		;�����4567����ʾ������Ϊ��ư��ֽ���λ������һ��һ���
		;����ʦд��ToDispaly��һ������
		ANL		KilometerBcd,#00001111B
		MOV		cDispBuffer+4,KilometerBcd;���λ
		MOV		A,KilometerBcd+1
		ANL		A,#11110000B
		SWAP	A
		MOV		cDispBuffer+5,A;
		ANL		KilometerBcd+1,#00001111B
		MOV		cDispBuffer+6,KilometerBcd+1;
		MOV		A,KilometerBcd+2
		ANL		A,#11110000B
		SWAP	A
		MOV		cDispBuffer+7,A;���λ

		;��λ��ϣ�����Ƶ�4-7����ʾ��
		;��ʾ��4-7��ʾ�����λ��ʼ����̡�	

		;������һ���жϣ�4��5����Ļ�ֱ����������������֣�
		;�������������0��û�б�Ҫ�����ٶȣ�ֻ���������ֳ���2�������Ҫ������� 
		MOV		A,cDispBuffer+4
		CJNE	A,#0,CalPrice
		MOV		A,cDispBuffer+5
		CJNE	A,#0,NextCondition
EndCal:
		JMP	EndCalculate;��������λ����0����ֱ�ӽ�������
NextCondition: ;10λ��0����λ����0�����
		CJNE	A,#1,CalPrice;�����λ����һ������2����ͼ���۸�
		JMP	EndCalculate  ;�����λֻ��1����Ҳ����Ҫ����۸񣨼��ͨ����
CalPrice:
		;��kilometer��ֵ����26
		MOV 	A,Kilometer+1
		MOV 	B,#1AH
		MUL 	AB
		MOV 	PriceBuffer1+2,A
		MOV 	PriceBuffer1+1,B 
		MOV 	A,Kilometer
		MOV 	B,#1AH
		MUL 	AB
		ADD 	A,PriceBuffer1+1
		MOV 	PriceBuffer1+1,A
		MOV 	PriceBuffer1,B
		;����֮�����28
		CLR 	C 
		MOV 	A,#1CH
		ADDC 	A,PriceBuffer1+2
		MOV 	PriceBuffer1+2,A 
		CLR 	A 
		ADDC 	A,PriceBuffer1+1
		MOV 	PriceBuffer1+1,A
		;���õ��ķ��ó���10�������ǵ��ö��ֽڳ������ڴ�׼��
		MOV Buffer,#0AH;��ֵ10��ʮ������
		MOV Buffer+1,#0
		MOV Buffer+2,#0
		MOV Buffer+3,#0
		MOV	Buffer+4,PriceBuffer1
		MOV	Buffer+5,PriceBuffer1+1
		MOV	Buffer+6,PriceBuffer1+2
		MOV Buffer+7,#0
		MOV	R0,#Buffer+1
		MOV	R1,#Buffer+2
		MOV	R6,#2
		MOV	R7,#6
		LCALL 	DivBytes
		MOV 	PriceBuffer1,Buffer+6
		MOV 	PriceBuffer1+1,Buffer+7
		;�����õ�ʮ����ת��Ϊʮ������
		MOV		R0,#PriceBuffer1
		MOV		R1,#PriceBuffer1Bcd
		LCALL	BinDec;����10����ת�����򣬵õ����10������
		;���¹����ǽ�ת���õ�10���Ʒ����������ֽڰ��˵���ʾ��������
		;�����4567����ʾ������Ϊ��ư��ֽ���λ������һ��һ���
		;����ʦд��ToDispaly��һ������
		ANL		PriceBuffer1Bcd,#00001111B
		MOV		cDispBuffer+4,PriceBuffer1Bcd;���λ
		MOV		A,PriceBuffer1Bcd+1
		ANL		A,#11110000B
		SWAP	A
		MOV		cDispBuffer+5,A;
		ANL		PriceBuffer1Bcd+1,#00001111B
		MOV		cDispBuffer+6,PriceBuffer1Bcd+1;
		MOV		A,PriceBuffer1Bcd+2
		ANL		A,#11110000B
		SWAP	A
		MOV		cDispBuffer+7,A;���λ	 
; ;ͨ��cDispBuffer�����10���ƹ��������������
; CalPrice:
; 		;��2.6�е�2��6�ֱ���Թ�������ÿһλ
; 		;��10���Ƴ˷�����
; 		;ȫ������10��������ʾ������һ���ڴ浥Ԫ��ʾ10������������һλ
	  
; 	   	;2.6*������
; 		;10��������
; 		;����ȡ�����λ���������

; 		MOV		A,cDispBuffer+7
; 		MOV		B,#6
; 		MUL		AB;��6 �����ȫ����A�У����ᵽB
; 		;A����˳�6�Ľ��������ֱ�ӳ�10
; 		MOV		B,#10
; 		DIV		AB	;��10
; 		MOV		PriceBuffer1+4,B
; 		MOV		Buffer,A
		
; 		MOV		R0,#cDispBuffer+6
; 		MOV		R1,#PriceBuffer1+3
; 		MOV		R2,#3
; Loop1:		
; 		MOV		A,@R0
; 		MOV		B,#6
; 		MUL		AB
; 		ADD		A,Buffer
; 		MOV		B,#10
; 		DIV		AB
; 		MOV		@R1,B
; 		MOV		Buffer,A
; 		DEC		R0
; 		DEC		R1
; 		DJNZ	R2,Loop1
; 		;��ȫ����0.6

; 		;��ȫ����2

				
; 		MOV		PriceBuffer1,Buffer
		
; 		MOV		A,cDispBuffer+7
; 		MOV		B,#2
; 		MUL		AB
; 		MOV		B,#10
; 		DIV		AB
; 		MOV		PriceBuffer2+3,B
; 		MOV		Buffer,A
		
; 		MOV		R0,#cDispBuffer+6
; 		MOV		R1,#PriceBuffer2+2
; 		MOV		R2,#3
; Loop2:
; 		MOV		A,@R0
; 		MOV		B,#2
; 		MUL		AB
; 		ADD		A,Buffer
; 		MOV		B,#10
; 		DIV		AB
; 		MOV		@R1,B
; 		MOV		Buffer,A
; 		DEC		R0
; 		DEC		R1
; 		DJNZ	R2,Loop2
		
; 		MOV		R0,#PriceBuffer1+3
; 		MOV		R1,#PriceBuffer2+3
; 		MOV		R2,#4
		
; 		MOV		Buffer,#0

; 		;��ȫ����2��ȫ����0.6�Ľ��������
; Loop3:
; 		MOV		A,@R0
; 		ADD		A,@R1
; 		ADD		A,Buffer
; 		MOV		B,#10
; 		DIV		AB
; 		MOV		Buffer,A
; 		MOV		@R0,B
; 		DEC		R0
; 		DEC		R1
; 		DJNZ	R2,Loop3
; 		;2.6*������

; 		;�������ã����������ķ���Ϊ2.6*������������2.8����8-2.6*2���õ�ʵ�ʵķ���
; 		MOV		A,PriceBuffer1+2
; 		ADD		A,#8
; 		MOV		B,#10
; 		DIV		AB
; 		MOV		PriceBuffer1+2,B
; 		MOV		Buffer,A
; 		MOV		A,PriceBuffer1+1
; 		ADD		A,#2
; 		ADD		A,Buffer
; 		MOV		B,#10
; 		DIV		AB
; 		MOV		PriceBuffer1+1,B
; 		MOV		Buffer,A
; 		MOV		A,PriceBuffer1
; 		ADD		A,Buffer
; 		MOV		PriceBuffer1,A
		
		;��ʾ����
		MOV		cDispBuffer,PriceBuffer1
		MOV		cDispBuffer+1,PriceBuffer1+1
		MOV		cDispBuffer+2,PriceBuffer1+2
		MOV		cDispBuffer+3,PriceBuffer1+3
EndCalculate:
		RET
;�۸���·�̼������	�����ͨ����

;������⳵���ٶ�
;ÿ���Ӽ���һ��

MyCalSpeed:;��������õ�R2
;����һ�ε��ֽ��루19BC��˫�ֽڵĳ˷�����������speed��speed+1,speed+2��Ԫ��)
		 MOV A,	IntOneSecond
		 CJNE A,#0H,DecreaseOne
         SJMP Cal

DecreaseOne:
		 DEC  IntOneSecond

		 Cal:
         CLR C
		 MOV Speed,#0H;
		 MOV Speed+1,#0H;
		 MOV Speed+2,#0H;
		 MOV SpeedBcd,#0H;		 
		 MOV SpeedBcd+1,#0H;
		 MOV SpeedBcd+2,#0H;
		 MOV SpeedBcd+3,#0H;


		 MOV A,	IntOneSecond
		 MOV B,#0BCH;������λ�˷�
		 MUL AB
		 MOV Speed+2,A
		 MOV Speed+1,B
		 
		 MOV A, IntOneSecond
		 MOV B,#19H
		 MUL AB
		 
		 ADDC A,Speed+1
		 MOV Speed+1,A
		 MOV A,B
		 ADDC A,#0H
		 MOV Speed,A

;�����ֽڵ�16������ת��10���Ƶķ���
Hex2Bcd3Byte:
		CLR C
		CLR A
		MOV R2,#24;���ֽڹ�24��ת��
   
		H2B3Loop:
		MOV A,Speed+2
		RLC A
		MOV Speed+2,A

		MOV A,Speed+1
		RLC A
		MOV Speed+1,A

		MOV A,Speed
		RLC A
		MOV Speed,A

		;��������ó���һλ����ʼ�ѻ���SpeedBcd��
		MOV A,SpeedBcd+3
		ADDC A,SpeedBcd+3
		DA A
		MOV SpeedBcd+3,A

		MOV A,SpeedBcd+2
		ADDC A,SpeedBcd+2
		DA A
		MOV SpeedBcd+2,A

		MOV A,SpeedBcd+1
		ADDC A,SpeedBcd+1
		DA A
		MOV SpeedBcd+1,A

		MOV A,SpeedBcd
		ADDC A,SpeedBcd
		DA A
		MOV SpeedBcd,A
		DJNZ R2,H2B3Loop;
;����λ�����ٶ��Ƶ���ʾ����
DisplaySpeed:
	;ֻ��ʾ	  SpeedBcd+1��SpeedBcd+2

	CLR A;��A����
	MOV R0,#cDispBuffer+11

	MOV A,SpeedBcd+2;�õ�SpeedBcd+1
	XCHD A,@R0;	����λ����
	RR A;��Aѭ��������λ
	RR A
	RR A
	RR A
	DEC R0
	XCHD A,@R0;

	DEC R0
	MOV A,SpeedBcd+1;�õ�SpeedBcd+1
	XCHD A,@R0;	����λ����
	RR A;��Aѭ��������λ
	RR A
	RR A
	RR A
	DEC R0
	XCHD A,@R0;

	CLR C;�������ٰ�C����
	MOV IntOneSecond,#0H
	ret
;��ʮ�������Ƶ���ʾ���ϵĺ���




;��λ����������	�����ͨ����
;����: R0-�������ֽڵ�ַ
;      R1-�������ֽڵ�ַ
;      R6-�����ֽ���
;      R7-���ֽ���
;���: ���ڱ�������λ�ã�������

;��������0x12345678/0x4321 = 456C
; mov Buffer+0,#0x43
; mov Buffer+1,#0x21
; mov Buffer+2,#0
; mov Buffer+3,#0
; mov Buffer+4,#0x12
; mov Buffer+5,#0x34
; mov Buffer+6,#0x56
; mov Buffer+7,#0x78
; mov r0,#Buffer+1
; mov r1,#Buffer+2
; mov r6,#2			;����λ��
; mov r7,#6			;������λ�����ϳ���λ��
; lcall DivBytes
; �����Buffer+4��ʼ�ĵط�����λ��ǰ


DivBytes:
		PUSH            5
		MOV             A,R7
		CLR             C
		SUBB            A,R6
		MOV             B,#8
		MUL             AB
		MOV             R5,A
DB1:
		PUSH            7
		PUSH            1
		MOV             A,R7
		ADD             A,R1
		DEC             A
		MOV             R1,A
		LCALL           ShiftL
		POP             1

		POP             7
		JC              DB21

		PUSH            6
		PUSH            1
		PUSH            0
		MOV             A,R1
		ADD             A,R6
		MOV             R1,A
		DEC             R1
DB2:
		MOV             A,@R1
		SUBB            A,@R0
		DEC             R1
		DEC             R0
		DJNZ            R6,DB2
		POP             0
		POP             1
		POP             6
		JC              DB4
DB21:
		PUSH            6
		PUSH            1
		PUSH            0
		MOV             A,R1
		ADD             A,R6
		MOV             R1,A
		DEC             R1
		CLR             C
DB3:
		MOV             A,@R1
		SUBB            A,@R0
		MOV             @R1,A
		DEC             R1
		DEC             R0
		DJNZ            R6,DB3
		MOV             A,R7
		ADD             A,R1
		MOV             R1,A
		INC             @R1
		POP             0
		POP             1
		POP             6
DB4:
		DJNZ            R5,DB1

		; 4 out 5 in
		MOV             A,@R1
		JB              ACC.7,DB5

		; remainder * 2
		PUSH            7
		PUSH            1
		MOV             A,R6
		ADD             A,R1
		DEC             A
		MOV             R1,A
		MOV             7,6
		LCALL           ShiftL
		POP             1

		POP             7
		CLR             C
		PUSH            6
		PUSH            1
		PUSH            0
		MOV             A,R1
		ADD             A,R6
		MOV             R1,A
		DEC             R1
		; divisor - remainder*2
DB7:
		MOV             A,@R1
		SUBB            A,@R0
		DEC             R1
		DEC             R0
		DJNZ            R6,DB7
		POP             0
		POP             1
		POP             6
		JC              DB6
DB5:
		MOV             A,R1
		ADD             A,R7
		MOV             R1,A
		DEC             R1
		MOV             A,R7
		CLR             C
		SUBB            A,R6
		MOV             R7,A
		SETB            C
DB8:
		MOV             A,@R1
		ADDC            A,#0
		MOV             @R1,A
		DEC             R1
		DJNZ            R7,DB8
DB6:
		POP             5
		RET
ShiftL:
		CLR             C
ShL1:
		MOV             A,@R1
		RLC             A
		MOV             @R1,A
		DEC             R1
		DJNZ            R7,ShL1
		RET


;��λ���������򣨼��ͨ����


; ��˫�ֽڵ�ʮ��������ת��ΪBCD�� �����ͨ����
; ����:  R0 - ʮ���������ĸ��ֽڵ�ַ
;        R1 - ת����BCD��ĸ�λ��ַ
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
; ��˫�ֽڵ�ʮ��������ת��ΪBCD��	 �����ͨ����


		END
