; 出租车计费器

;定义全局变量（检查通过） 
cDispBuffer		EQU		10H		;一共12块屏幕，一共12字节 10H - 1BH
cDisplayBit		EQU		1CH	    ;正在显示的屏幕	  1CH

cOneSecond		EQU		1DH		;时间中断达到1秒指示位
cOneMSecond     EQU		1EH	   	;时间中断达到1毫秒指示位

IntOneSecond	EQU		1FH		;记录一秒内外部中断次数，单字节
TotalInto		EQU		20H		;累加所有外部中断次数，双字节 20H-21H

Kilometer		EQU		23H		;总公里数(高位地址)，三字节	 23H-25H
KilometerBcd			EQU		28H		;总公里数(高位地址)，四字节	 27H-30H

Speed			EQU		32H		;速度(高位地址)，三字节		32H-34H
SpeedBcd		EQU		36H		;速度bcd码(高位地址)，四字节  36H-39H

Buffer			EQU		40H		;多字节除法缓冲区

PriceBuffer1		EQU		50H		;总费用数(高位地址)，三字节	 50H-52H
PriceBuffer1Bcd			EQU		53H		;总公里数(高位地址)，四字节	 53H-56H


		ORG		0000H
		LJMP		Initialization    ;主循环

		ORG		0003H
		LJMP		Intro ;外部中断0

		ORG		000BH
		LJMP		TimerInto ;内部计数器中断0

		ORG		30H

;初始化变量（检查通过）
Initialization:	
		MOV		SP,#60H;设置堆栈指针
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
		MOV 	cOneMSecond,#0 ;时钟中断指示器

		MOV		IntOneSecond,#0
		MOV		TotalInto,#0
		MOV		TotalInto+1,#0 ;两个外部中断累加器

		
		;中断初始化，定时器赋初值，设置好外部中断（检查通过）			
		;设置定时器
		MOV		TMOD,#01H
		SETB	TR0
		SETB	ET0
		MOV		TH0,#0F8H	 												;0x0FA2A
		MOV		TL0,#0CDH
	   	
		;设置外部中断
		SETB	EX0
		SETB	EA
		SETB	IT0	

;初始化变量（检查通过）

	;	MOV cMotorCount,#56H
	;	MOV cMotorCount+1,#5H
MainLoop:;主循环
		;每隔1秒钟计算一次速度.
		;不断计算并显示里程
	

		JNB		P3.7,Stop;等待P3.7被置1，即按钮被按下
		SETB	EX0	;空语句
		SETB	IT0	;空语句
		SJMP	MainLoop ;循环
Stop:  ;按钮被按下就停止
		CLR		EX0	   ;关闭中断系统
		CLR		IT0		;改成电平触发		
		SJMP	MainLoop ;循环

;外部中断跳转（检查通过）
;外部中断用于模拟速度，中断的时候执行简单加一
Intro:	
		PUSH PSW
		PUSH ACC
	  	CLR 	C  ;保证C位为0
		MOV		A,TotalInto   ;对中断次数cMotorCount，双字节增加1
		ADDC		A,#1		   ;对中断次数cMotorCount，双字节增加1
		MOV		TotalInto,A  ;对中断次数cMotorCount，双字节增加1
		MOV		A,TotalInto+1;对中断次数cMotorCount，双字节增加1
		ADDC	A,#0		   ;对中断次数cMotorCount，双字节增加1
		MOV		TotalInto+1,A;对中断次数cMotorCount，双字节增加1
		INC		IntOneSecond ;增加一秒内的中断次数
		POP ACC
		POP PSW 
		RETI
;外部中断跳转 （检查通过） 
  
;时钟中断跳转（检查通过）
;设置1ms的定时中断，不断调用显示的扫描程序
;用一个变量，每中断一次加1，到了10后置上bt10ms标志
TimerInto:
		LCALL	Display

		INC		cOneMSecond
		MOV 	TH0,#0F8H
		MOV		TL0,#0CDH ;延时1ms用F8CD
		MOV		A,cOneMSecond
		CJNE 	A,#10,EndTimerInto;若中断之后没有到10次则直接返回

		LCALL	CalculateDistance  ;如果已经到10，则计算一次里程

		MOV 	cOneMSecond,#0;定时中断归0重新算10次
		INC 	cOneSecond;每10ms 就增加一次秒指示器
		MOV		A,cOneSecond;秒数放到A寄存器用来判断跳转
		CJNE 	A,#100,EndTimerInto ;一秒等于1000ms
		MOV 	cOneSecond,#0;秒指示器清0

		LCALL 	MyCalSpeed;每秒计算一次速度

EndTimerInto:

		RETI	;时钟中断返回
;时钟中断跳转（检查通过）


;显示屏函数	（检查通过）
;P1.7为小数点   
;数码管扫描程序，在定时中断里调用
DispTable:	DB		3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH;仍然使用原来的10个数字的晶体管显示矩阵
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

		;考虑哪些位需要加上小数点
		MOV		A,cDisplayBit;取出目前显示的屏幕
		CJNE	A,#1,Next1
		SETB	P1.7 ;1号屏加小数点
Next1:	;5号屏幕增加小数点
		CJNE	A,#5,Next2
		SETB	P1.7
Next2:	;7号屏加小数点
		CJNE	A,#10,Next3
		SETB	P1.7 ;10号显示屏加小数点
Next3:
		INC		cDisplayBit	;显示屏移到下一块
		MOV 	A,cDisplayBit
		CJNE	A,#12,EndDisp
		MOV 	cDisplayBit,#0;这两步相当于将显示屏限制在0-12之间，相当于取模运算mod 12
EndDisp:		
		RET
;显示屏函数	（检查通过）


;计算并显示总里程（检查通过）
CalculateDistance:
		MOV		A,TotalInto ;取外部中断总数
		MOV		B,#0B7H;周长是1.83，所以这里用183进行运算
		;进行双字节与单字节（0B7H）相乘的步骤
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
		;完成单字节与双字节乘法，结果放Kilometer的三个字节中	

		;下面组装多位数除法程序的参数
		;16进制的里程数除100
		MOV Buffer,#64H;数值100的十六进制
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
		LCALL	DivBytes ;调用多字节除法程序						 
		MOV	Kilometer,Buffer+6
		MOV	Kilometer+1,Buffer+7 ;将得到的除100以后的里程数重新放回里程数的存储空间
		
		;下面开始将公里转成10进制
		;将16进制与10进制公里的内存位置放到R0和R1，作转10进制程序的参数准备	
		MOV		R0,#Kilometer
		MOV		R1,#KilometerBcd
		LCALL	BinDec;调用10进制转换程序，得到里程10进制码
		;以下过程是将转换好的10进制里程数按半字节搬运到显示缓冲区中
		;里程是4567号显示屏，因为设计半字节移位，所以一块一块搬
		;和老师写的ToDispaly是一个作用
		ANL		KilometerBcd,#00001111B
		MOV		cDispBuffer+4,KilometerBcd;最高位
		MOV		A,KilometerBcd+1
		ANL		A,#11110000B
		SWAP	A
		MOV		cDispBuffer+5,A;
		ANL		KilometerBcd+1,#00001111B
		MOV		cDispBuffer+6,KilometerBcd+1;
		MOV		A,KilometerBcd+2
		ANL		A,#11110000B
		SWAP	A
		MOV		cDispBuffer+7,A;最低位

		;移位完毕，里程移到4-7号显示屏
		;显示屏4-7显示从最高位开始的里程。	

		;以下做一个判断，4，5号屏幕分别持有里程数整数部分；
		;如何整数部分是0就没有必要计算速度，只有整数部分超过2公里才需要计算费用 
		MOV		A,cDispBuffer+4
		CJNE	A,#0,CalPrice
		MOV		A,cDispBuffer+5
		CJNE	A,#0,NextCondition
EndCal:
		JMP	EndCalculate;若整数两位都是0，则直接结束计算
NextCondition: ;10位是0，个位不是0的情况
		CJNE	A,#1,CalPrice;如果个位大于一，就是2公里，就计算价格
		JMP	EndCalculate  ;如果个位只是1，则也不需要计算价格（检查通过）
CalPrice:
		;将kilometer的值乘上26
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
		;乘完之后加上28
		CLR 	C 
		MOV 	A,#1CH
		ADDC 	A,PriceBuffer1+2
		MOV 	PriceBuffer1+2,A 
		CLR 	A 
		ADDC 	A,PriceBuffer1+1
		MOV 	PriceBuffer1+1,A
		;将得到的费用除以10，下面是调用多字节除法的内存准备
		MOV Buffer,#0AH;数值10的十六进制
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
		;将费用的十进制转化为十六进制
		MOV		R0,#PriceBuffer1
		MOV		R1,#PriceBuffer1Bcd
		LCALL	BinDec;调用10进制转换程序，得到里程10进制码
		;以下过程是将转换好的10进制费用数按半字节搬运到显示缓冲区中
		;里程是4567号显示屏，因为设计半字节移位，所以一块一块搬
		;和老师写的ToDispaly是一个作用
		ANL		PriceBuffer1Bcd,#00001111B
		MOV		cDispBuffer+4,PriceBuffer1Bcd;最高位
		MOV		A,PriceBuffer1Bcd+1
		ANL		A,#11110000B
		SWAP	A
		MOV		cDispBuffer+5,A;
		ANL		PriceBuffer1Bcd+1,#00001111B
		MOV		cDispBuffer+6,PriceBuffer1Bcd+1;
		MOV		A,PriceBuffer1Bcd+2
		ANL		A,#11110000B
		SWAP	A
		MOV		cDispBuffer+7,A;最低位	 
; ;通过cDispBuffer保存的10进制公里数，计算费用
; CalPrice:
; 		;将2.6中的2与6分别乘以公里数的每一位
; 		;做10进制乘法运算
; 		;全过程用10进制来表示，即用一个内存单元表示10进制数的其中一位
	  
; 	   	;2.6*公里数
; 		;10进制运算
; 		;首先取出最低位的里程数字

; 		MOV		A,cDispBuffer+7
; 		MOV		B,#6
; 		MUL		AB;乘6 ，结果全部在A中，不会到B
; 		;A存放了乘6的结果，所以直接除10
; 		MOV		B,#10
; 		DIV		AB	;除10
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
; 		;先全部乘0.6

; 		;再全部乘2

				
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

; 		;将全部乘2和全部乘0.6的结果加起来
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
; 		;2.6*公里数

; 		;调整费用，上面计算出的费用为2.6*公里数，加上2.8即（8-2.6*2）得到实际的费用
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
		
		;显示费用
		MOV		cDispBuffer,PriceBuffer1
		MOV		cDispBuffer+1,PriceBuffer1+1
		MOV		cDispBuffer+2,PriceBuffer1+2
		MOV		cDispBuffer+3,PriceBuffer1+3
EndCalculate:
		RET
;价格与路程计算完毕	（检查通过）

;计算出租车的速度
;每秒钟计算一次

MyCalSpeed:;这个函数用到R2
;进行一次单字节与（19BC）双字节的乘法，结果存放在speed，speed+1,speed+2单元中)
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
		 MOV B,#0BCH;先做低位乘法
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

;将三字节的16进制数转成10进制的方法
Hex2Bcd3Byte:
		CLR C
		CLR A
		MOV R2,#24;三字节共24次转换
   
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

		;将从左边拿出的一位数开始堆积到SpeedBcd区
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
;把四位数的速度移到显示屏上
DisplaySpeed:
	;只显示	  SpeedBcd+1和SpeedBcd+2

	CLR A;将A清零
	MOV R0,#cDispBuffer+11

	MOV A,SpeedBcd+2;拿到SpeedBcd+1
	XCHD A,@R0;	低四位交换
	RR A;将A循环向右移位
	RR A
	RR A
	RR A
	DEC R0
	XCHD A,@R0;

	DEC R0
	MOV A,SpeedBcd+1;拿到SpeedBcd+1
	XCHD A,@R0;	低四位交换
	RR A;将A循环向右移位
	RR A
	RR A
	RR A
	DEC R0
	XCHD A,@R0;

	CLR C;出函数再把C清零
	MOV IntOneSecond,#0H
	ret
;把十进制数移到显示屏上的函数




;多位数除法程序	（检查通过）
;输入: R0-除数高字节地址
;      R1-除数低字节地址
;      R6-除数字节数
;      R7-总字节数
;结果: 商在被除数的位置，余数在

;例：计算0x12345678/0x4321 = 456C
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
; mov r6,#2			;除数位数
; mov r7,#6			;被除数位数加上除数位数
; lcall DivBytes
; 结果在Buffer+4开始的地方，高位在前


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


;多位数除法程序（检查通过）


; 把双字节的十六进制数转换为BCD码 （检查通过）
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
; 把双字节的十六进制数转换为BCD码	 （检查通过）


		END
