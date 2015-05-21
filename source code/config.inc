;___________________________________________________________________
;___________________________________________________________________
;Copyright :    2015 by HOLTEK SEMICONDUCTOR INC
;File Name :    config.inc
;Targer :       Oximeter_TestBoard
;MCU :          HT66F4540
;Version :      V00
;Author :       ChenTing
;Date :         2015/01/15
;Description :  系統配置選項
;History : 
;___________________________________________________________________
;___________________________________________________________________
include HT68F002.inc
include MACRO.inc
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;#define OPA1_Enable
;#define	OPA2_Enable
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#define SysFrequency			4000000
#define IIC_Device_Addr_Default 028H
#define IIC_Time_Out_Count		200
#define Enable					1
#define Disable					0
					;-----ISR VECTOR Defination------;
;中斷入口地址
#define	START_VECTOR			000H		;主程序開始地址
#define INT0_VECTOR				004H		;外部中斷0
#define Timebase0_VECTOR		008H		;timebase0中斷
#define Timebase1_VECTOR		00CH		;timebase0中斷
#define M_FUNCTION0_VECTOR		010H		;多功能中斷0---STM P/A
#define EEPROM_VECTOR			014H		;EEPROM中斷
#define ADC_VECTOR				018H		;ADC中斷
;#define M_FUNCTION1_VECTOR		01CH		;多功能中斷1---PTM P/A Only for HT68F003
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;					;---------------System init---------------;
;;SYSFrequency
#define SYSFrequency_8MHz		00000001B
#define SYSFrequency_4MHz		11100000B
#define SYSFrequency_2MHz		11000000B
#define SYSFrequency_1MHz		10100000B

if SysFrequency==8000000
#define SYSFrequency_Default	SYSFrequency_8MHz
endif
if SysFrequency==4000000
#define SYSFrequency_Default	SYSFrequency_4MHz
endif
if SysFrequency==2000000
#define SYSFrequency_Default	SYSFrequency_2MHz
endif
if SysFrequency==1000000
#define SYSFrequency_Default	SYSFrequency_1MHz
endif
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;WDT
#define WDT_Time_Disable		10101000B
#define WDT_Time7_8ms			01010000B	;2^8/F_LIRC
#define WDT_Time15_6ms			01010001B	;2^9/F_LIRC
#define WDT_Time31_3ms			01010010B	;2^10/F_LIRC
#define WDT_Time62_5ms			01010011B	;2^11/F_LIRC
#define WDT_Time125ms			01010100B	;2^12/F_LIRC
#define WDT_Time250ms			01010101B	;2^13/F_LIRC
#define WDT_Time500ms			01010110B	;2^14/F_LIRC
#define WDT_Time1000s			01010111B	;2^15/F_LIRC
#define WDT_Function_Default	WDT_Time62_5ms
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;PA7/RES PIN
#define Share_PA7				01010101B	;PA7 或其他引腳功能
#define Share_RES				10101010B	;RES 引腳
#define	ADC_Clock_Default		Share_PA7
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;LVD低電壓偵測
#define LVD_Disable				00000000B	;Disable LVD功能
#define LVD_Voltage2_0			00010000B	;LVD 2.0V
#define LVD_Voltage2_2			00010001B	;LVD 2.2V
#define LVD_Voltage2_4			00010010B	;LVD 2.4V
#define LVD_Voltage2_7			00010011B	;LVD 2.7V
#define LVD_Voltage3_0			00010100B	;LVD 3.0V
#define LVD_Voltage3_3			00010101B	;LVD 3.3V
#define LVD_Voltage3_6			00010110B	;LVD 3.6V
#define LVD_Voltage4_0			00010111B	;LVD 4.0V
#define	LVD_Voltage_Default		LVD_Voltage2_2
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;INT0
#define INT0_Disable			00H
#define INT0_Falling			01H
#define INT0_Rising				02H
#define INT0_Dualing			03H
#define INT0_Default			INT0_Dualing
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@