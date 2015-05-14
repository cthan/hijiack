;___________________________________________________________________
;___________________________________________________________________
;Copyright:	2015 by HOLTEK SEMICONDUCTOR INC
;File name:	target.inc
;Version: 	V00
;Targer:	HT68F002
;Author: 	ChenTing
;Date:		2015/04/10
;Description:系統硬件接口設定，定義需要的使用的通信、按鍵IO
;History: 
;___________________________________________________________________
;___________________________________________________________________

;include HT66F4540.inc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;----------------------------START------------------------------;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;功能選擇
;#define UART_Enable
#define IIC_Enable


;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#define hijack_channel_R		PA1
#define hijack_channel_L		PA6
#define hijack_channel_MIC		PA2
#define hijack_channel_R_IO 	PAC1
#define hijack_channel_L_IO 	PAC6
#define hijack_channel_MIC_IO 	PAC2
#define hijack_channel_R_PU 	PAPU1
#define hijack_channel_L_PU		PAPU6
#define hijack_channel_MIC_PU	PAPU2
 
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			;--------IIC PORT--------;
ifdef IIC_Enable
	#define IIC_SDA		PA5			;IIC DATA IO 定義
	#define IIC_SCL		PA4			;IIC SCK  IO  定義
	#define IIC_SDA_IO  PAC5		;輸入輸出定義
	#define IIC_SCL_IO  PAC4		;輸入輸出定義
	#define IIC_SDA_PU	PAPU5		;內部上拉電阻定義
	#define IIC_SCL_PU  PAPU4		;內部上拉電阻定義
endif
			;--------UART PROT-------;
ifdef UART_Enable
	#define UART_TX		PA4			;UART MCU輸出引腳 定義
	#define UART_RX		PA5			;UART MCU輸入引腳 定義
	#define UART_TX_IO  PAC4		;輸入輸出定義
	#define UART_RX_IO  PAC5		;輸入輸出定義
	#define UART_TX_PU	PAPU4		;內部上拉電阻定義
	#define UART_RX_PU  PAPU5		;內部上拉電阻定義
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-----------------------------END-------------------------------;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;