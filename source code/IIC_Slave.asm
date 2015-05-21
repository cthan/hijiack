;___________________________________________________________________
;___________________________________________________________________
;Copyright :    2015 by HOLTEK SEMICONDUCTOR INC
;File Name :    sysinit.asm
;Targer :       hijack TEST Board
;MCU :          HT68F002
;Version :      V00
;Author :       ChenTing
;Date :         2015/04/10
;Description :  音頻通信程序測試
;				IIC_Slave程序
;History : 
;___________________________________________________________________
;___________________________________________________________________
include config.inc
include target.inc
;include IICSlave.inc

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@---------------------Library API------------------------------@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
EXTERN	R_STATUS 			:BYTE
EXTERN	R_ATEMP 			:BYTE
EXTERN	Flag_SDA_Status		:BIT

Public 	_IIC_INT_ISR
public  IIC_Receive_Data_High
public	IIC_Receive_Data_Low
public	IIC_Send_Data_High
public	IIC_Send_Data_Low
public  _IIC_init
public	IIC_RXok_Flag		
public	IIC_TXok_Flag		
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@------------------------------DATA----------------------------@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
rambank 0  IIC_Slave_datal
IIC_Slave_datal	.section	'data'   

IIC_Device_Addr			DB	?
IIC_Receive_Data_High	DB	?
IIC_Receive_Data_Low	DB	?
IIC_Send_Data_High		DB	?
IIC_Send_Data_Low		DB	?
IIC_temp_conunt1		DB	?
IIC_temp_conunt2		DB	?
IIC_temp_BYTE			DB	?
IIC_RXok_Flag			DBIT
IIC_TXok_Flag			DBIT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@-------------------------------CODE---------------------------@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IIC_Slave_code	.section	'code' 

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 _IIC_INT_ISR PROC
 		PUSH
 		CLR		INTE 		
		SNZ		Flag_SDA_Status
		JMP		_IIC_RET
		CLR		Flag_SDA_Status
;判斷是否為有效start信號
		SNZ		IIC_SCL		
		JMP		_IIC_RET				;SDA下降沿的時候，SCL為low，不是IIC start信號
		MOV		A,IIC_Time_Out_Count
		MOV		IIC_temp_conunt2,A
$1:					
		SNZ		IIC_SCL				;SCL高電平就等待
		JMP		$2
		SDZ		IIC_temp_conunt2
		JMP		$1
$2:		
;讀取Device address
		CALL	_IIC_Read_BYTEData		;讀取IIC 主機發送過來的設備地址
Device_Addr_Judge:	;判斷地址是否匹配
		MOV		A,IIC_temp_BYTE
		MOV		IIC_Device_Addr,A
		MOV		A,0feH					;取出地址數據		
		AND		A,IIC_Device_Addr
		XOR		A,IIC_Device_Addr_Default
		SNZ		Z
		JMP		_IIC_RET				;地址不匹配，則退出
;地址匹配，發送ACK給主機
		CALL	IIC_Ack					;收到設備地址，對設備地址ACK應答		
;地址匹配，判斷主機需要讀取數據還是寫入數據
		MOV		A,01H					;取出地址數據		
		AND		A,IIC_Device_Addr
		SZ		ACC
		JMP		IIC_Master_Read			;主機需要讀取數據
		JMP		IIC_Master_Write		;主機需要寫入數據
IIC_Master_Read:
		MOV		A,IIC_Send_Data_High
		MOV		IIC_temp_BYTE,A
		CALL	_IIC_Write_BYTEData
		CALL	IIC_Ack					;收到1byte數據，ACK應答
		MOV		A,IIC_Send_Data_High
		MOV		IIC_temp_BYTE,A
		CALL	_IIC_Write_BYTEData		
		JMP		_IIC_Tx_OK_RET
	
IIC_Master_Write:		
		CALL	_IIC_Read_BYTEData
		MOV		A,IIC_temp_BYTE
		MOV		IIC_Receive_Data_High,A
;修改為雙字節
		CALL	IIC_Ack					;收到1byte數據，ACK應答		
		CALL	_IIC_Read_BYTEData
		MOV		A,IIC_temp_BYTE
		MOV		IIC_Receive_Data_Low,A
		JMP		_IIC_Rx_Ok_RET
		
_IIC_Tx_OK_RET:
		SET		IIC_TXok_Flag
		JMP		_IIC_RET
_IIC_Rx_Ok_RET:
		SET		IIC_RXok_Flag
		JMP		_IIC_RET
_IIC_RET:
		SET		INTE
		CLR		INTF
		POP
		RETI
_IIC_INT_ISR ENDP


;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@	
_IIC_Read_BYTEData PROC
		SET		IIC_SDA_IO
		MOV 	A,9 				;SET 8 BIT COUNTER
		MOV 	IIC_temp_conunt1,A	
		CLR		IIC_temp_BYTE
IIC_Read_LOOP:	
		SDZ 	IIC_temp_conunt1 	;8bit值是否已經讀取完成
		JMP		IIC_Read_BYTEData_LOOP
		RET
IIC_Read_BYTEData_LOOP:	
		RL	 	IIC_temp_BYTE		;高位在前
		MOV		A,IIC_Time_Out_Count;config time out value
		MOV		IIC_temp_conunt2,A		
$1:						
		SZ		IIC_SCL				;SCL低電平狀態就等待
		JMP		$2
		SDZ		IIC_temp_conunt2
		JMP		$1
		RET
$2:					
		SNZ		IIC_SDA				;讀取到來的data值
		JMP		SDA_LOW0
		JMP		SDA_HIGH0
SDA_HIGH0:
		SET		IIC_temp_BYTE.0
		JMP		IIC_Read_Next					
SDA_LOW0:
		CLR		IIC_temp_BYTE.0
IIC_Read_Next:		
		MOV		A,IIC_Time_Out_Count
		MOV		IIC_temp_conunt2,A
$1:					
		SNZ		IIC_SCL				;SCL高電平就等待
		JMP		IIC_Read_LOOP
		SDZ		IIC_temp_conunt2
		JMP		$1		
		RET	
_IIC_Read_BYTEData ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@	
_IIC_Write_BYTEData PROC
		CLR		IIC_SDA_IO
		MOV 	A,8 ;SET 8 BIT COUNTER
		MOV 	IIC_temp_conunt1,A
		MOV		A,IIC_Time_Out_Count
		MOV		IIC_temp_conunt2,A						
IIC_Write_BYTEData_LOOP:
		SZ		IIC_SCL				;SCL低電平狀態就等待
		JMP		$2
		SDZ		IIC_temp_conunt2
		JMP		IIC_Write_BYTEData_LOOP
		RET
$2:			
;		MOV		A,80H				;取出地址數據		
;		AND		A,IIC_temp_BYTE
;		SZ		ACC
		SZ		IIC_temp_BYTE.7
		JMP		SDA_HIGH1
		JMP		SDA_LOW1
SDA_HIGH1:
		SET		IIC_SDA
		JMP		Write_Next_Bit
SDA_LOW1:
		CLR		IIC_SDA
Write_Next_Bit:
		MOV		A,IIC_Time_Out_Count
		MOV		IIC_temp_conunt2,A	
$2:					
		SNZ		IIC_SCL				;SCL高電平就等待
		JMP		$1
		SDZ		IIC_temp_conunt2
		JMP		$2
		RET		
$1:		
;		SET		IIC_SDA_IO				;讓出數據線
		RL		IIC_temp_BYTE
		SDZ 	IIC_temp_conunt1 	;8bit值是否已經讀取完成
		JMP		IIC_Write_BYTEData_LOOP
		SET		IIC_SDA_IO				;讓出數據線
		RET	
_IIC_Write_BYTEData ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IIC_Ack PROC
;應答信號，保證在兩個時鐘條邊沿SDA為低，則主機認為是從機應答
		CLR		IIC_SDA_IO			;config SDA output
		MOV		A,IIC_Time_Out_Count
		MOV		IIC_temp_conunt2,A
$1:
		SZ		IIC_SCL				;低電平就等待
		JMP		$2
		SDZ		IIC_temp_conunt2
		JMP		$1
		RET
$2:			
		CLR		IIC_SDA		;第9個CLK變高的情況下，SDA輸出0
		MOV		A,IIC_Time_Out_Count
		MOV		IIC_temp_conunt2,A
$3:				
		SNZ		IIC_SCL
		JMP		$4
		SDZ		IIC_temp_conunt2
		JMP		$3
		RET
$4:				
		SET		IIC_SDA_IO		;第9個CLK變低的情況下，釋放總線
		RET
IIC_Ack ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
_IIC_init PROC
		CLR		IIC_SDA
		SET		IIC_SDA_IO		;輸出話IO口設定
		SET		IIC_SCL_IO	
		CLR		IIC_SCL
		

		MOV		A,INT0_Default	;config INT觸發中斷
		MOV		INTEG,A
		CLR		INTF
		SET		INTE
		SET		EMI				;使能INT
				
		RET
_IIC_init ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

