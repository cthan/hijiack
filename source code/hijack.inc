;___________________________________________________________________
;___________________________________________________________________
;Copyright:	2015 by HOLTEK SEMICONDUCTOR INC
;File name:	target.inc
;Version: 	V00
;Targer:	HT68F002
;Author: 	ChenTing
;Date:		2015/04/27
;Description:hijack相關定義
;History: 
;___________________________________________________________________
;___________________________________________________________________
;include config.inc
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;#
;#hijack FSK頻率
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#define stmCCRP_T		512	
#define fskFrequency0	1378
#define fskFrequency1	fskFrequency0/2				;Fsk high的頻率為low的一半
#define fskDelaycount0	(1000000/fskFrequency0)/2	;high low延遲為T/2
#define fskDelaycount1	(1000000/fskFrequency1)/2	;high low延遲為T/2
#define hijack_Time_Out	40					;T >= 128*40=5120us  Frequency <= 195Hz
#define	Tolerance		65							;允許收到週期的時間差為±60us
#define hijack_Period0_Max	1000000/fskFrequency0 + Tolerance	;
#define hijack_Period0_Min	1000000/fskFrequency0 - Tolerance	;
#define hijack_Period1_Max	1000000/fskFrequency1 + Tolerance	;
#define hijack_Period1_Min	1000000/fskFrequency1 - Tolerance	;
