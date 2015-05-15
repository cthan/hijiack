;___________________________________________________________________
;___________________________________________________________________
;Copyright :    2015 by HOLTEK SEMICONDUCTOR INC
;File Name :    main.asm
;Targer :       hijack Board
;MCU :          HT68F002
;Version :      V00
;Author :       ChenTing
;Date :         2015/04/10
;Description :  hijack 音頻通信測試
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
EXTERN	IIC_Receive_Data 		:BYTE
EXTERN	IIC_Send_Data 			:BYTE
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@------------------------Library API------------------------------@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
public	F_EMI
public	R_ATEMP
public  R_STATUS
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@-----------------------------DATA--------------------------------@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
ds	.section	'data'    
F_EMI					DBIT
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
        JMP		_IIC_INT_ISR		;IIC從機子程序
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
		MOV		IIC_Send_Data,A
		CLR		PAC3
		SET		PA3
		MOV		A,0A5H
		MOV		hijack_Send_Data_High,A
		MOV		A,05AH
		MOV		hijack_Send_Data_Low,A
		
MAIN:

		CLR		WDT
		CLR		WDT1
		CLR		WDT2
		NOP
		CLR		EMI
		CALL	_hijack_Send
	
		JMP		MAIN


