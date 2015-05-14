;===========DELAY=====================
;======delay_time=3*value*fsys/4======
DELAY	MACRO	VALUE        
		MOV		A,VALUE
		CLR		WDT
		SDZ		acc
		JMP		$-1
		ENDM

;==========NEJMP=======================   
;======IF(VALUE2!=VALUE1)JUMP==========	   	
NEJMP	MACRO	VALUE2,VALUE1	
		MOV		A,VALUE1
		XOR		A,VALUE2
		SZ		Z
		ENDM

;=========LBRJ========================
;=======;IF(VALUE3<VALUE4)JUMP========
LBRJ    MACRO   VALUE3,VALUE4
        MOV     A,VALUE3
        SUB     A,VALUE4
        SZ      C
        ENDM

;==========MMOV=======================                      
MMOV	MACRO   A1,A2
		MOV		A,A2
        MOV		A1,A
        ENDM

;============POP======================
POP	MACRO
		MOV		A,R_STATUS
		MOV		STATUS,A
		MOV		A,R_ATEMP
		ENDM

;============PUSH=====================
PUSH	MACRO
		MOV		R_ATEMP,A
		MOV		A,STATUS
		MOV		R_STATUS,A
		ENDM
;====================================