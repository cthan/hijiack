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
;				系統初始化程序
;History : 
;___________________________________________________________________
;___________________________________________________________________
include config.inc
include target.inc
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@---------------------Library API------------------------------@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
Public 	_CLEAR_RAM
Public 	_INIT_PORT
Public	_INIT_WDT
public  _INIT_SysFrequency
public  _INIT_LVD

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

						;-----------Clear RAM----------;
;@SUBROUTINE
;HT66F4540 , bank0:40h-FFh  )
_CLEAR_RAM PROC
        mov     A,040H          
        mov     MP0,A           
        mov     A,64d          
CLEAR_RAM_LOOP:                    
        clr     IAR0            
        inc     MP0             
        SDZ     ACC             
        JMP     CLEAR_RAM_LOOP     
        RET
_CLEAR_RAM ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
						;----------Initial Port----------;
;SUBROUTINE
_INIT_PORT PROC
        MOV     A,00H
        MOV     PA,A        
        MOV     A,00H
        MOV     PAC,A      
        MOV		A,00H
        MOV		PAPU,A       
        MOV		A,00H
        MOV		PAWU,A

		MOV		A,00H
		MOV		PASR,A

		SET		PAC6		
		SET		PAC1
		SET		PAWU1	        	
        RET
_INIT_PORT ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
						;----------Initial WDTC----------;
;SUBROUTINE
_INIT_WDT PROC
	    MOV		A,WDT_Function_Default
	    MOV		WDTC,A    	
        RET
_INIT_WDT ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@       
						;----------Initial SysFrequency----------;
;SUBROUTINE
_INIT_SysFrequency PROC
	    MOV		A,SYSFrequency_Default
	    MOV		SMOD,A    	
        RET
_INIT_SysFrequency ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  
						;----------Initial LVD----------;
;SUBROUTINE
_INIT_LVD PROC
	    MOV		A,LVD_Voltage_Default
	    MOV		LVDC,A    	
        RET
_INIT_LVD ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  
						;----------Initial EMI----------;
;SUBROUTINE
;_INIT_LVD PROC
;	    MOV		A,LVD_Voltage_Default
;	    MOV		LVDC,A    	
;        RET
;_INIT_LVD ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 