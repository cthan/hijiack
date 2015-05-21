;___________________________________________________________________
;___________________________________________________________________
;Copyright :    2015 by HOLTEK SEMICONDUCTOR INC
;File Name :    main.asm
;Targer :       hijack Board
;MCU :          HT68F002
;Version :      V00
;Author :       ChenTing
;Date :         2015/04/10
;Description :  hijack ���W�q�H����
;History : 
;___________________________________________________________________
;___________________________________________________________________

include config.inc
include target.inc
include hijack.inc
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@------------------------Library API------------------------------@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
EXTERN  _CLEAR_RAM				:NEAR
EXTERN  _INIT_PORT				:NEAR 
EXTERN  _INIT_WDT				:NEAR
EXTERN  _INIT_SysFrequency		:NEAR
EXTERN  _INIT_LVD				:NEAR
EXTERN  _IIC_INT_ISR			:NEAR
EXTERN  _IIC_init				:NEAR

EXTERN  _hijack_Receive			:NEAR
EXTERN  _hijack_Send			:NEAR
EXTERN  _hijack_init			:NEAR

EXTERN	hijack_Receive_DataH	:BYTE
EXTERN	hijack_Receive_DataL	:BYTE
EXTERN	hijack_Send_Data_High	:BYTE
EXTERN	hijack_Send_Data_Low	:BYTE
EXTERN	IIC_Receive_Data_High	:BYTE
EXTERN	IIC_Receive_Data_Low	:BYTE
EXTERN	IIC_Send_Data_High 		:BYTE
EXTERN	IIC_Send_Data_Low 		:BYTE
EXTERN	IIC_RXok_Flag			:BIT
EXTERN	IIC_TXok_Flag			:BIT
EXTERN	Hijack_RxOk_Flag		:BIT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@------------------------Library API------------------------------@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
public	F_EMI
public	R_ATEMP
public  R_STATUS
public	Flag_SDA_Status
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@-----------------------------DATA--------------------------------@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
ds	.section	'data'    
F_EMI					DBIT
Flag_SDA_Status			DBIT
R_ATEMP					DB	?
R_STATUS				DB	?

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@-----------------------------CODE--------------------------------@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
cs	.section	at  000h	'code'
        ORG     START_VECTOR
        SNZ     TO
        JMP     POWER_ON
        JMP     MAIN
;ISR VECTOR Defination
        ORG     INT0_VECTOR
        JMP		_IIC_INT_ISR		;IIC�q���l�{��
        RETI
;
        ORG		Timebase0_VECTOR 
        RETI
;
		ORG		Timebase1_VECTOR
		RETI
;
		ORG		M_FUNCTION0_VECTOR
		JMP		_hijack_Receive
		RETI
;
		ORG		EEPROM_VECTOR
		RETI
;
		ORG		ADC_VECTOR
		RETI
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
					;---------Power ON-------------;
POWER_ON:
		CALL	_CLEAR_RAM
		CALL	_INIT_PORT
		CALL	_INIT_WDT
		CALL	_INIT_SysFrequency
		CALL	_INIT_LVD
		CALL	_IIC_init
		CALL	_hijack_init
		MOV		A,000H
		MOV		IIC_Send_Data_High,A
		CLR		PAC3
		SET		PA3
		MOV		A,058H
		MOV		hijack_Send_Data_High,A
		MOV		A,014H
		MOV		hijack_Send_Data_Low,A
		
MAIN:
;��´���hijack�o�e�����W
		CLR		WDT
		CLR		WDT1
		CLR		WDT2
		CLR		EMI
		CALL	_hijack_Send
		INC		hijack_Send_Data_Low
		JMP		Main

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;�P�_�i�JIIC���_�eSDA�����A�A�Ω�P�_Start�H���Mstop�H��		
		SET		IIC_SDA_IO
		SNZ		IIC_SDA
		JMP		SDA_LOW0
		JMP		SDA_High0
SDA_High0:
		SET		Flag_SDA_Status
		JMP		Main_LOOP
SDA_LOW0:
		CLR		Flag_SDA_Status
Main_LOOP:		
		CLR		WDT
		CLR		WDT1
		CLR		WDT2
;IIC�������\�A�N�ƾڥ�hijack�o�e�X�h			
		SZ		IIC_RXok_Flag
		JMP		Movedata2Hijack	
;hijack�������\�A�N�ƾڵo�eIIC���A���ѵ��D��Ū��		
		SZ		Hijack_RxOk_Flag
		JMP		Movedata2IIC
		JMP		MAIN
		
Movedata2IIC:
		CLR		Hijack_RxOk_Flag
		MOV		A,hijack_Receive_DataH
		MOV		IIC_Send_Data_High,A
		MOV		A,hijack_Receive_DataL
		MOV		IIC_Send_Data_Low,A
		JMP		MAIN
Movedata2Hijack:
		CLR		IIC_RXok_Flag
		MOV		A,IIC_Receive_Data_High
		MOV		hijack_Send_Data_High,A
		MOV		A,IIC_Receive_Data_Low
		MOV		hijack_Send_Data_Low,A
		CALL	_hijack_Send
		JMP		MAIN
		
		
;Read_SDA_Status	PROC
;		SET		IIC_SDA_IO
;		SNZ		IIC_SDA
;		JMP		SDA_LOW
;		JMP		SDA_High
;SDA_High:
;		SET		Flag_SDA_Status
;		RET
;SDA_LOW:
;		CLR		Flag_SDA_Status
;		RET
;Read_SDA_Status	ENDP		