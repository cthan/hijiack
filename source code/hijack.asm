;___________________________________________________________________
;___________________________________________________________________
;Copyright :    2015 by HOLTEK SEMICONDUCTOR INC
;File Name :    hijack.asm
;Targer :       hijack TEST Board
;MCU :          HT68F002
;Version :      V00
;Author :       ChenTing
;Date :         2015/04/10
;Description :  音頻通信程序測試
;				音頻通信主要程序
;History : 
;___________________________________________________________________
;___________________________________________________________________
include config.inc
include target.inc
include hijack.inc
;#define IIC_Device_Addr_Default 0A0H
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@---------------------Library API------------------------------@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
EXTERN	F_EMI 		:BIT
EXTERN	R_STATUS 			:BYTE
EXTERN	R_ATEMP 			:BYTE
 
public  _hijack_init
Public 	_hijack_Receive
public  _hijack_Send

public	hijack_Send_Data
public	hijack_Receive_DataH
public	hijack_Receive_DataL

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@------------------------------DATA----------------------------@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
rambank 0  hijack_datal
hijack_datal	.section	'data'   

hijack_Receive_DataH		DB	?
hijack_Receive_DataL		DB	?
hijack_Send_Data			DB	?
hijack_temp_Byte			DB	?
hijack_temp_count1			DB	?
hijack_temp_count2			DB	?
hijack_CCRP_count			DB	?
hijack_Rx_step				DB	?
high_CCRA1_H				DB	?
high_CCRA1_L				DB	?
high_CCRA2_H				DB	?
high_CCRA2_L				DB	?
hijack_Period_H				DB	?
hijack_Period_L				DB	?
TEST_COUNT					DB	?
TEST_COUNT2					DB	?
TEST_COUNT3					DB	?
hijack_Idle_Count			DB	?
hijack_Rx_Count				DB	?
hijack_Rx_Parity_Count		DB	?

F_First_CCRA				DBIT
F_hijack_Rx_Error			DBIT
F_hijack_Rx_Start			DBIT
F_CompleteRx1Bit			DBIT
F_0or1Bit					DBIT
F_PrepareMode				DBIT
F_IdleMode					DBIT
F_ByteMode					DBIT
F_hijackstartOk				DBIT
F_Parity_StopMode			DBIT
F_Parity_Ok					DBIT
F_Stop_idleMode				DBIT
F_First_Parity_StopMode		DBIT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@-------------------------------CODE---------------------------@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
hijack_code	.section	'code' 

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
_hijack_Send PROC
		CLR		IIC_SCL_IO;
		CLR		IIC_SCL		;hijack發送數據的時候拉低SCL，不接收IICdata
		SNZ		EMI
		JMP		$1
		SET		F_EMI
		JMP		$2			
$1:		
		CLR		F_EMI		
		JMP		$2
$2:		
		CLR		EMI		;關閉總中斷，防止其他程序打斷
		CLR		hijack_channel_MIC_IO 
		SET		hijack_channel_MIC
;建立Bias信號 12bit 0
		CALL	_hijack_Send_Bias		
;idel信號     3bit  1
		CALL	_hijack_Send_Idle
;start信號	  1bit  0
		CALL	_hijack_Send_Start				
;發送1Byte data + 奇校驗
		MOV		A,0A5H
		MOV		hijack_temp_Byte,A		
		CALL	_hijack_Send_Byte		
;stop信號	  1bit 1
		CALL	_hijack_Send_Stop
;3bit結束信號
		CALL	_hijack_Send_Idle

		SNZ		F_EMI
		JMP		_hijack_Send_RET
		SET		EMI			;開啟EMI，
_hijack_Send_RET:
		CLR		F_EMI
		RET 
_hijack_Send ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;						_hijack_Receive	Start							@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
_hijack_Receive PROC
		PUSH
		SNZ		F_hijack_Rx_Start
		JMP		hijack_Normal_Mode
hijack_Rx_Mode:		
		CALL	_hijack_Rx_1Bit		
		CALL	_hijack_PrepareMode	
		CALL	_hijack_StartIdleMode		
		CALL	_hijack_Rx_Byte				
		CALL	_hijack_Parity_StopMode
		CALL	_hijack_ENDIdleMode
		
		SNZ		F_hijack_Rx_Error
		JMP		_hijack_Receive_RET
		CLR		F_First_CCRA
		CLR		F_hijack_Rx_Error
		CLR		TEST_COUNT
		CLR		TEST_COUNT2
		CLR		F_ByteMode
		CLR		F_CompleteRx1Bit
		CLR		F_IdleMode
		CLR		F_PrepareMode
		CLR		F_hijack_Rx_Start
		CLR		F_hijackstartOk
		JMP		_hijack_Receive_RET


		
hijack_Normal_Mode:	
		SNZ		STMA0F
		JMP		_hijack_Normal_CCRP_RET	;(not hijack Rx mode)& (not CCRA interrupt) = normal CCRP interrupt
;;第一次進入CCRA中斷，初始化相關設置	init hijack Rx Value
		MOV		A,00001000B
		XORM	A,PA
		CLR		STMA0F		
		SET		F_First_CCRA
		CLR		hijack_CCRP_count	
		MOV		A,STM0AH					;Save CCRA value
		MOV		high_CCRA1_H,A	;
		MOV		A,STM0AL					;
		MOV		high_CCRA1_L,A	;
		INC		TEST_COUNT3
		SET		F_hijack_Rx_Start
		SET		F_PrepareMode
		MOV		A,3
		MOV		hijack_Idle_Count,A
		CLR		F_hijack_Rx_Error				
		JMP		_hijack_Receive_RET			
_hijack_Normal_CCRP_RET:
		SNZ		STMP0F					;CCRP_interrupt也不是 CCRP_interrupt中斷，錯誤
		SET		F_hijack_Rx_Error
		CLR		STMP0F		
_hijack_Receive_RET:
		
		POP		
		RETI 
_hijack_Receive ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;					_hijack_Receive	End		    						@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
_hijack_Parity_StopMode PROC
		SNZ		F_Parity_StopMode
		RET
		SNZ		F_CompleteRx1Bit
		RET
		CLR		F_CompleteRx1Bit
		
		SZ		F_Parity_Ok
		JMP		Stop_Deal					
		SNZ		hijack_Rx_Parity_Count.0
		JMP		Paritylow
		JMP		ParityHigh
ParityHigh:	
		SNZ		F_0or1Bit
		JMP		_hijack_Parity_StopMode_Error
		SET		F_Parity_Ok
		JMP		_hijack_Parity_StopMode_RET					
ParityLow:		
		SZ		F_0or1Bit
		JMP		_hijack_Parity_StopMode_Error
		SET		F_Parity_Ok
		JMP		_hijack_Parity_StopMode_RET			
Stop_Deal:
		CLR		F_Parity_Ok
		SNZ		F_0or1Bit
		JMP		_hijack_Parity_StopMode_Error
		SET		F_Stop_idleMode
		MOV		A,3
		MOV		hijack_Idle_Count,A
		CLR		F_Parity_StopMode				
		JMP		_hijack_Parity_StopMode_RET
_hijack_Parity_StopMode_Error:
		SET		F_hijack_Rx_Error
		RET	
_hijack_Parity_StopMode_RET:			
		RET
_hijack_Parity_StopMode ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
_hijack_PrepareMode PROC
		SNZ		F_PrepareMode
		RET
		SNZ		F_CompleteRx1Bit
		RET
;		INC		TEST_COUNT2
		CLR		F_CompleteRx1Bit
;Idle		
		SNZ		F_0or1Bit
		RET
		CLR		F_PrepareMode
		SET		F_IdleMode
		RET
_hijack_PrepareMode ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
_hijack_StartIdleMode PROC
		SNZ		F_IdleMode
		RET
;Idle		
		SNZ		F_CompleteRx1Bit
		RET
		CLR		F_CompleteRx1Bit
		SDZ		hijack_Idle_Count
		JMP		$1
$0:		
		SZ		F_0or1Bit
		JMP		$2
		CLR		F_IdleMode
		SET		F_ByteMode
		RET
$2:		
		SET		F_hijack_Rx_Error	;第四bit 還是1，錯誤
		RET
$1:		
		SZ		F_0or1Bit		
		RET						
		SET		F_hijack_Rx_Error	;3bit 1 Idle 不夠
		RET				
_hijack_StartIdleMode ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
_hijack_ENDIdleMode PROC
		SNZ		F_Stop_idleMode
		RET
		SNZ		F_CompleteRx1Bit
		RET
		CLR		F_CompleteRx1Bit
		INC		TEST_COUNT
		SDZ		hijack_Idle_Count
		JMP		$1
$0:		
		SZ		F_0or1Bit
		
		CLR		F_IdleMode
		SET		F_ByteMode
		RET
$2:		
		SET		F_hijack_Rx_Error	;第四bit 還是1，錯誤
		RET
$1:		

		SZ		F_0or1Bit		
		RET						
		SET		F_hijack_Rx_Error	;3bit 1 Idle 不夠
		RET					
_hijack_ENDIdleMode ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
_hijack_Rx_Byte PROC
		SNZ		F_ByteMode
		RET
		SNZ		F_CompleteRx1Bit
		RET
		CLR		F_CompleteRx1Bit		
		SNZ		F_hijackstartOk
		JMP		$0
		JMP		hijack_Rx_ByteEnter
$0:
		SNZ		F_0or1Bit
		JMP		$1
		SET		F_hijack_Rx_Error
		RET
$1:
		SET		F_hijackstartOk
		MOV		A,16
		MOV		hijack_Rx_Count,A
		CLR		hijack_Receive_DataH
		CLR		hijack_Receive_DataL
		CLR		hijack_Rx_Parity_Count
		RET										
hijack_Rx_ByteEnter:
		SDZ 	hijack_Rx_Count 	;16bit值是否已經讀取完成	
		JMP		hijack_Rx_Byte_LOOP
		SET		F_CompleteRx1Bit
		SET		F_Parity_StopMode	;進入下一個模式
		CLR		F_ByteMode			
		RET
hijack_Rx_Byte_LOOP:
		CLR		C
		RLC		hijack_Receive_DataL
		RLC		hijack_Receive_DataH		
		
		SNZ		F_0or1Bit
		JMP		hijack_Low
		JMP		hijack_High
hijack_High:
		INC		hijack_Rx_Parity_Count
		SET		hijack_Receive_DataL.0
		JMP		hijack_Next_Bit
hijack_Low:
		CLR		hijack_Receive_DataL.0
hijack_Next_Bit:
		RET
_hijack_Rx_Byte ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
_hijack_Rx_1Bit PROC
		SNZ		STMP0F
		JMP		CCRA_interrupt
CCRP_interrupt:					
		CLR		STMP0F
		INC		hijack_CCRP_count
		MOV		A,hijack_CCRP_count
		XOR		A,hijack_Time_Out		
		SNZ		Z
		RET
		JMP		_hijack_Rx_1Bit_Error ;超出時間，錯誤
CCRA_interrupt:
		SNZ		STMA0F
		JMP		_hijack_Rx_1Bit_Error ;不是CCRA 中斷也不是CCRP中斷，錯誤
		CLR		STMA0F
;		INC		TEST_COUNT
		MOV		A,00001000B
		XORM	A,PA
		SZ		F_First_CCRA
		JMP		Second_CCRA
First_CCRA:	;第一次CCRA中斷 上升沿									
		SET		F_First_CCRA
		MOV		A,STM0AH					;Save CCRA value
		MOV		high_CCRA1_H,A	
		MOV		A,STM0AL					
		MOV		high_CCRA1_L,A	
		MOV		A,hijack_CCRP_count
		MOV		hijack_Period_L,A			;保存CCRP 的計數值
		CLR		hijack_CCRP_count
;		INC		TEST_COUNT
;計算週期
;N x 512-high_First_CCRA_Count + high_Second_CCRA_Count
if stmCCRP_T==512
		MOV		A,9
		MOV		hijack_temp_count1,A 		;根據CCRP 的值修改移位的值
endif
if stmCCRP_T==256
		MOV		A,8
		MOV		hijack_temp_count1,A 		;根據CCRP 的值修改移位的值
endif
$0:
		CLR		C 							;移位進行乘法運算
		RLC		hijack_Period_L
		RLC		hijack_Period_H	
		SDZ		hijack_temp_count1
		JMP		$0		
		CLR		C							
		MOV		A,high_CCRA1_L				;加上第二次取得的CCRA 的值
		ADDM	A,hijack_Period_L
		MOV		A,high_CCRA1_H
		ADCM	A,hijack_Period_H		
		CLR		C 
		MOV		A,hijack_Period_L			;減去第一次取得的 CCRA 的值
		SUB		A,high_CCRA2_L
		MOV		hijack_Period_L,A
		MOV		A,hijack_Period_H
		SBC		A,high_CCRA2_H
		MOV		hijack_Period_H,A		

		JMP		hijack_Period					
Second_CCRA:;第二次CCRA中斷 上升沿
		CLR		F_First_CCRA
		MOV		A,STM0AH					;Save CCRA value
		MOV		high_CCRA2_H,A	;
		MOV		A,STM0AL					;
		MOV		high_CCRA2_L,A	;
		MOV		A,hijack_CCRP_count
		MOV		hijack_Period_L,A			;保存CCRP 的計數值
		CLR		hijack_CCRP_count
;		INC		TEST_COUNT		
;計算週期
;N x 512-high_First_CCRA_Count + high_Second_CCRA_Count
if stmCCRP_T==512
		MOV		A,9
		MOV		hijack_temp_count1,A 		;根據CCRP 的值修改移位的值
endif
if stmCCRP_T==256
		MOV		A,8
		MOV		hijack_temp_count1,A 		;根據CCRP 的值修改移位的值
endif
$0:
		CLR		C 							;移位進行乘法運算
		RLC		hijack_Period_L
		RLC		hijack_Period_H	
		SDZ		hijack_temp_count1
		JMP		$0		
		CLR		C							
		MOV		A,high_CCRA2_L				;加上第二次取得的CCRA 的值
		ADDM	A,hijack_Period_L
		MOV		A,high_CCRA2_H
		ADCM	A,hijack_Period_H		
		CLR		C 
		MOV		A,hijack_Period_L			;減去第一次取得的 CCRA 的值
		SUB		A,high_CCRA1_L
		MOV		hijack_Period_L,A
		MOV		A,hijack_Period_H
		SBC		A,high_CCRA1_H
		MOV		hijack_Period_H,A		
hijack_Period:		
;判斷是否是0
hijack_Period_0:
;		INC		TEST_COUNT				
		MOV		A,hijack_Period_H
		XOR		A,5					;hijack_Period0_Max 高八位
		SNZ		Z
		JMP		hijack_Period_1				;高Byte不相等，判斷是否為Bit 1
;高位相等，判斷低八位是否在容差範圍內		
        MOV     A,hijack_Period_L
        SUB     A,94H +Tolerance 
        SZ      C		
		JMP		_hijack_Rx_1Bit_Error		;週期太大錯誤
        MOV     A,hijack_Period_L
        SUB     A,94H - Tolerance 
        SNZ      C			
		JMP		_hijack_Rx_1Bit_Error		;週期太小錯誤
		CLR		F_0or1Bit					;由週期判斷為Bit 0
		JMP		_hijack_Rx_1Bit_RET
hijack_Period_1:	;是否在294H~316H之間		
		MOV		A,hijack_Period_H
		XOR		A,2					;hijack_Period1_Max 高八位
		SZ		Z
		JMP		highByte2				;==2，判斷是否在294~300之間
;是否==3
		MOV		A,hijack_Period_H
		XOR		A,3					;hijack_Period1_Max 高八位
		SZ		Z
		JMP		highByte3	
		JMP		_hijack_Rx_1Bit_Error	;高Byte既不是2也不是3，錯誤
highByte3: ;300~316H
        MOV     A,hijack_Period_L
        SUB     A,016H
        SZ      C
        JMP		_hijack_Rx_1Bit_Error
        JMP		thisis1		
highByte2:		
;294H~300H之間
        MOV     A,hijack_Period_L
        SUB     A,094H
        SNZ      C
        JMP		_hijack_Rx_1Bit_Error
        JMP		thisis1
thisis1:
		SET		F_0or1Bit
		JMP		_hijack_Rx_1Bit_RET				

_hijack_Rx_1Bit_RET:
		SET		F_CompleteRx1Bit		
		RET
_hijack_Rx_1Bit_Error:
		SET		F_hijack_Rx_Error		;CCRP 連續發生的次數超過設定值(週期時間太長 Error)
		RET								;置錯誤標誌位
_hijack_Rx_1Bit ENDP



	

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
_hijack_init PROC
if stmCCRP_T==512
		MOV		A,00000100B	;4/fsys  512 CCRP interrput
		MOV		STM0C0,A
endif
if stmCCRP_T==256
		MOV		A,00000010B	;4/fsys  512 CCRP interrput
		MOV		STM0C0,A
endif	
		MOV		A,01000000B	;輸入捕捉模式、上升沿觸發、P 清除time
		MOV		STM0C1,A
		
		SET		hijack_channel_L_IO
		CLR		hijack_channel_L
		
		CLR		STP0IPS		;STP0I on PA6
		
		SET		STMA0E		;開啟Timer 輸入捕捉模式中斷
		SET		STMP0E
		SET		MF0E
		CLR		MF0F
		CLR		STMA0F
		CLR		STMP0F
		SET		ST0ON
		SET		EMI
		RET
_hijack_init ENDP




;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
_hijack_Send_Byte PROC
;		local temp  D
 		CLR		hijack_channel_MIC
 		MOV		A,8 ;SET 8 BIT COUNTER
 		MOV		hijack_temp_count1,A
 		CLR		hijack_temp_count2		;作為奇偶校驗位計數
hijack_send_8bitloop:
		SZ		hijack_temp_Byte.7
		JMP		hijack_send_high
		JMP		hijack_send_low
hijack_send_high:
		INC		hijack_temp_count2		;奇校驗
		SET		hijack_channel_MIC
		DELAY	fskDelaycount1/3		;Delay延遲了3倍，so fskDelaycount0/3為正確值
		CLR		hijack_channel_MIC
		DELAY	fskDelaycount1/3		;Delay延遲了3倍，so fskDelaycount0/3為正確值
		JMP		hijack_send_Next_Bit	
hijack_send_low:		
		SET		hijack_channel_MIC	;
		DELAY	fskDelaycount0/3		;Delay延遲了3倍，so fskDelaycount0/3為正確值
		CLR		hijack_channel_MIC
		DELAY	fskDelaycount0/3		;Delay延遲了3倍，so fskDelaycount0/3為正確值 		
hijack_send_Next_Bit:
		RL		hijack_temp_Byte
		SDZ		hijack_temp_count1
		JMP		hijack_send_8bitloop
hijack_send_odd_Bit:
		SZ		hijack_temp_count2.0
		JMP		hijack_send_odd_Bit_Low
;		JMP		hijack_odd_Bit_high
hijack_send_odd_Bit_high:
		SET		hijack_channel_MIC
		DELAY	fskDelaycount1/3		;Delay延遲了3倍，so fskDelaycount0/3為正確值
		CLR		hijack_channel_MIC
		DELAY	fskDelaycount1/3		;Delay延遲了3倍，so fskDelaycount0/3為正確值
		JMP		_hijack_Send_Byte_RET		
hijack_send_odd_Bit_Low:
		SET		hijack_channel_MIC	;
		DELAY	fskDelaycount0/3		;Delay延遲了3倍，so fskDelaycount0/3為正確值
		CLR		hijack_channel_MIC
		DELAY	fskDelaycount0/3		;Delay延遲了3倍，so fskDelaycount0/3為正確值 							
_hijack_Send_Byte_RET:
		RET 
_hijack_Send_Byte ENDP
;;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
_hijack_Send_Bias PROC
;用於先建立bias
 		MOV		A,12 ;SET 8 BIT COUNTER
 		MOV		hijack_temp_count1,A
$1:		
		SET		hijack_channel_MIC	;
		DELAY	fskDelaycount0/3		;Delay延遲了3倍，so fskDelaycount0/3為正確值
		CLR		hijack_channel_MIC
		DELAY	fskDelaycount0/3		;Delay延遲了3倍，so fskDelaycount0/3為正確值 		
		SDZ		hijack_temp_count1
		JMP		$1					
		RET
_hijack_Send_Bias ENDP
;;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
_hijack_Send_Idle PROC
;,3bit 1頻率的idle信號，用於信號發送的開始和結束
 		MOV		A,3 					;SET 8 BIT COUNTER
 		MOV		hijack_temp_count1,A
$1: 		
		SET		hijack_channel_MIC	;
		DELAY	fskDelaycount1/3		;Delay延遲了3倍，so fskDelaycount0/3為正確值
		CLR		hijack_channel_MIC
		DELAY	fskDelaycount1/3		;Delay延遲了3倍，so fskDelaycount0/3為正確值
		SDZ		hijack_temp_count1
		JMP		$1
		RET	
_hijack_Send_Idle ENDP
;;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
_hijack_Send_Start PROC
;1bit 0頻率 用於開始信號,		
		SET		hijack_channel_MIC	;
		DELAY	fskDelaycount0/3		;Delay延遲了3倍，so fskDelaycount0/3為正確值
		CLR		hijack_channel_MIC
		DELAY	fskDelaycount0/3		;Delay延遲了3倍，so fskDelaycount0/3為正確值
		RET	
_hijack_Send_Start ENDP
;;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
_hijack_Send_Stop PROC
;1bit 1頻率用於結束信號,		
		SET		hijack_channel_MIC	;
		DELAY	fskDelaycount1/3		;Delay延遲了3倍，so fskDelaycount0/3為正確值
		CLR		hijack_channel_MIC
		DELAY	fskDelaycount1/3		;Delay延遲了3倍，so fskDelaycount0/3為正確值
		RET	
_hijack_Send_Stop ENDP