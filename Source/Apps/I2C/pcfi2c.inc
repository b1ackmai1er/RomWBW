;==================================================================================================
; PCF8584 Generic 
;==================================================================================================
;
PCF_BASE  	.EQU  0F0H
PCF_ID   	.EQU  0AAH
CPU_CLK	  	.EQU  12

PCF_RS0     	.EQU  PCF_BASE
PCF_RS1    	.EQU  PCF_RS0+1
PCF_OWN	 	.EQU  (PCF_ID >> 1)        	; PCF'S ADDRESS IN SLAVE MODE

REGS0     	.EQU  PCF_BASE
REGS1    	.EQU  REGS0+1
;
;T4LC512D	.EQU	10100000B		; DEVICE IDENTIFIER
;T4LC512A1	.EQU	00000000B		; DEVICE ADDRESS
;T4LC512A2	.EQU	00001110B		; DEVICE ADDRESS
;T4LC512A3	.EQU	00000010B		; DEVICE ADDRESS
;T4LC512W	.EQU	00000000B		; DEVICE WRITE
;T4LC512R	.EQU	00000001B		; DEVICE READ
;
;I2CDEV1W  	.EQU	(T4LC512D+T4LC512A1+T4LC512W)
;I2CDEV1R	.EQU	(T4LC512D+T4LC512A1+T4LC512R)
;
;I2CDEV2W  	.EQU	(T4LC512D+T4LC512A2+T4LC512W)
;I2CDEV2R	.EQU	(T4LC512D+T4LC512A2+T4LC512R)
;
;I2CDEV3W  	.EQU	(T4LC512D+T4LC512A3+T4LC512W)
;I2CDEV3R	.EQU	(T4LC512D+T4LC512A3+T4LC512R)
;
; CONTROL REGISTER BITS
;
PCF_PIN  	.EQU  10000000B
PCF_ES0  	.EQU  01000000B
PCF_ES1  	.EQU  00100000B
PCF_ES2  	.EQU  00010000B
PCF_EN1  	.EQU  00001000B
PCF_STA  	.EQU  00000100B
PCF_STO  	.EQU  00000010B
PCF_ACK  	.EQU  00000001B
;
PCF_START_    	.EQU  (PCF_PIN | PCF_ES0 | PCF_STA | PCF_ACK)
PCF_STOP_     	.EQU  (PCF_PIN | PCF_ES0 | PCF_STO | PCF_ACK)
PCF_REPSTART_ 	.EQU  (          PCF_ES0 | PCF_STA | PCF_ACK)
PCF_IDLE_     	.EQU  (PCF_PIN | PCF_ES0           | PCF_ACK)
;
; STATUS REGISTER BITS
;
;PCF_PIN  	.EQU  10000000B
PCF_INI   	.EQU  01000000B   ; 1 if not initialized 
PCF_STS   	.EQU  00100000B
PCF_BER   	.EQU  00010000B
PCF_AD0   	.EQU  00001000B
PCF_LRB   	.EQU  00001000B
PCF_AAS   	.EQU  00000100B
PCF_LAB   	.EQU  00000010B
PCF_BB    	.EQU  00000001B
;
; CLOCK CHIP FREQUENCIES
;
PCF_CLK3   	.EQU	000H
PCF_CLK443 	.EQU	010H
PCF_CLK6   	.EQU	014H
PCF_CLK8   	.EQU	018H
PCF_CLK12  	.EQU	01cH
;
; TRANSMISSION FREQUENCIES
;
PCF_TRNS90 	.EQU	000H	;  90 kHz */
PCF_TRNS45 	.EQU	001H	;  45 kHz */
PCF_TRNS11 	.EQU	002H	;  11 kHz */
PCF_TRNS15 	.EQU	003H	; 1.5 kHz */
;
; TIMEOUT AND DELAY VALUES (ARBITRARY)
;
PCF_PINTO	.EQU	65000
PCF_ACKTO	.EQU	65000
PCF_BBTO	.EQU	65000
PCF_LABDLY	.EQU	65000
;
; DATA PORT REGISTERS
;
#IF (CPU_CLK = 443)
PCF_CLK .EQU PCF_CLK443
#ELSE 
 #IF (CPU_CLK = 8)
PCF_CLK .EQU PCF_CLK8
 #ELSE 
  #IF (CPU_CLK = 12)
PCF_CLK .EQU PCF_CLK12
  #ELSE ***ERROR
  #ENDIF
 #ENDIF	
#ENDIF
;
DS7_OUT		.EQU	10000000B		; SELECT SQUARE WAVE FUNCTION
DS7_SQWE	.EQU	00010000B		; ENABLE SQUARE WAVE OUTPUT
DS7_RATE	.EQU	00000000B		; SET 1HZ OUPUT
;
DS7_DS1307    	.EQU  	11010000B   		; DEVICE IDENTIFIER
DS7_W   	.EQU  	00000000B   		; DEVICE WRITE
DS7_R   	.EQU  	00000001B   		; DEVICE READ
;
DS7_READ   	.EQU    (DS7_DS1307 | DS7_R)	; READ
DS7_WRITE 	.EQU    (DS7_DS1307 | DS7_W)	; WRITE
;
DS7_CTL		.EQU	(DS7_OUT | DS7_SQWE | DS7_RATE)
;
PCF8574   	.EQU 	01000000B    		; DEVICE IDENTIFIER
PCF8574A  	.EQU 	00001110B    		; DEVICE ADDRESS
PCF8574W  	.EQU 	00000000B    		; DEVICE WRITE 
PCF8574R  	.EQU 	00000001B    		; DEVICE READ
;	
I2CLCDR  	.EQU  (PCF8574+PCF8574A+PCF8574R)
I2CLCDW  	.EQU  (PCF8574+PCF8574A+PCF8574W) 
