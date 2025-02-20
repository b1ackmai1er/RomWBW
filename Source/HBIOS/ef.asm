;======================================================================
;	EF9345 DRIVER FOR ROMWBW
;
;	PARTS WRITTEN BY: ALAN COX
;	REVISED/ENHANCED BY LASZLO SZOLNOKI -- 01/2024
;======================================================================
; TODO:
;	- 40X24 IMPLEMENTATION
;======================================================================
; EF9345 DRIVER - CONSTANTS
;======================================================================
;
TERMENABLE	.SET	TRUE      	; INCLUDE TERMINAL PSEUDODEVICE DRIVER
;
EF_BASE		.EQU	$F0
EF_SETREG	.EQU	EF_BASE + 4
EF_DATAACC	.EQU	EF_BASE + 5
EF_RESET	.EQU	EF_BASE + 6
;
EF_SIZE		.EQU	V80X24
;
EF_R0		.EQU	$20
EF_R1		.EQU	EF_R0+1
EF_R2		.EQU	EF_R0+2
EF_R3		.EQU	EF_R0+3
EF_R4		.EQU	EF_R0+4
EF_R5		.EQU	EF_R0+5
EF_R6		.EQU	EF_R0+6
EF_R7		.EQU	EF_R0+7
;
EF_XA		.EQU	EF_R5
EF_YA		.EQU	EF_R4
EF_XP		.EQU	EF_R7
EF_YP		.EQU	EF_R6
;
EF_EXEC		.EQU	00001000b
;
EF_TGSREG	.EQU 	1
EF_MATREG	.EQU	2
EF_PATREG	.EQU	3
EF_DORREG	.EQU	4
EF_RORREG	.EQU	7
;EF_WRTINDIR	.EQU 10000000b
;
; CMD
;
EF_NOP		.EQU	$91		;
EF_IND		.EQU	$80		;
EF_CLF		.EQU	$05		;
EF_OCT		.EQU	$30		;
EF_OCTAUX	.EQU	$04		; AUXILIARY POINTER
EF_KRF		.EQU	$00		; NO AUTOINCREMENT
EF_KRL		.EQU	$50		; NO AUTOINCREMENT
EF_INY		.EQU	$B0		; INC Y
;
;EF_IND_TGS	.EQU	$81
;EF_IND_MAT	.EQU	$82
;EF_IND_PAT	.EQU	$83
;EF_IND_DOR	.EQU	$84
;EF_IND_ROR	.EQU	$87
EF_RREG		.EQU	00001000b
;EF_WREG	.EQU    ~EF_RREG
;
; | 1 | 0 | 0| 0| R/!W | r | r | r |   IND command
;                        0   0   1     TGS
;                        0   1   0     MAT
;                        0   1   1     PAT
;                        1   0   0     DOR
;                        1   0   1
;                        1   1   0
;                        1   1   1     ROR
;						MAT5	MAT4
; fixed complemented	  0		  0
; flash complemented	  1		  0
; fixed underlined		  0		  1
; flash underlined		  1		  1
;
EF_NOCU		.EQU	10111111B	; MAT6 = 0 : NO CURSOR
EF_BLK		.EQU	00100000B	; MAT5 = 1 : BLINK CURSOR
EF_NOBL		.EQU	11011111B	; MAT5 = 0 : NO BLINK
;
EF_BLOK		.EQU	11101111b	; MAT4 = 0 : BLOCK CURSOR
EF_ULIN		.EQU	00010000b	; MAT4 = 1 : UNDERLINE CURSOR
;
EF_CURENA	.EQU	TRUE		; ENABLE CURSOR
;
EF_MARCOL	.EQU	00000000B	; MARGIN COLOR BLACK : MAT0 = R, MAT1 = G, MAT2 = B
EF_MARENA	.EQU	00001000B	; MARGIN INSERT : MAT3 = 1
;
EF_CUREN	.EQU	01000000B	; MAT6 = 1 : CURSOR ENABLED
EF_DISCU	.EQU	10111111B	; MAT6 = 0 : NO CURSOR
;
EF_BLINK	.EQU	00100000B	; MAT5 = 1 : BLINK CURSOR
EF_NOBLINK	.EQU	11011111B	; MAT5 = 0 : NO BLINK
;
EF_COMPL	.EQU	11101111b	; MAT4 = 0 : BLOCK CURSOR
;
EF_FLASHCHAR	.EQU    00001000B
EF_REVERSCHAR	.EQU    10000000B
;
#IF EF_CURENA
EF_CSTY 	.EQU	EF_CUREN | EF_BLINK | EF_ULIN | EF_MARENA | EF_MARCOL
#ELSE
EF_CSTY 	.EQU	EF_MARENA | EF_MARCOL
#ENDIF
;
FIRSTLINE	.EQU	8
;
#IF (EF_SIZE=V80X24)			; V80X24
EF_DLINES	.EQU	24
EF_DROWS	.EQU	80
EF_DSCANL	.EQU	10
; ATTRIBUTES
EF_FLASH	.EQU	01000100B
EF_NEGATIVE	.EQU	10001000B
EF_UNDERLINE	.EQU	00100010B
EF_COLORSET	.EQU	00010001B
#ENDIF
;
#IF (EF_SIZE=V40X24)
EF_DLINES	.EQU	24
EF_DROWS	.EQU	40
EF_DSCANL	.EQU	10
; ATTRIBUTES
EF_FLASH	.EQU	01000100B
EF_NEGATIVE	.EQU	10001000B
EF_UNDERLINE	.EQU	00100010B
EF_COLORSET	.EQU	00010001B
#ENDIF
;
; DISTRICTS
;
EF_DIST0 	.EQU 	0
EF_DIST1 	.EQU 	$20
EF_DIST2 	.EQU 	$80
EF_DIST3 	.EQU 	$A0
;
EF_BG_BLACK	.EQU	$0
EF_BG_RED	.EQU	$10
EF_BG_GREEN	.EQU	$20
EF_BG_BROWN	.EQU	$30
EF_BG_BLUE	.EQU	$40
EF_BG_MAGENTA	.EQU	$50
EF_BG_CYAN	.EQU	$60
EF_BG_WHITE	.EQU	$70
EF_FG_BLACK	.EQU	0
EF_FG_RED	.EQU	1
EF_FG_GREEN	.EQU	2
EF_FG_BROWN	.EQU	3
EF_FG_BLUE	.EQU	4
EF_FG_MAGENTA	.EQU	5
EF_FG_CYAN	.EQU	6
EF_FG_WHITE	.EQU	7
;
EF_SCREENSIZE	.EQU	EF_DROWS * EF_DLINES
;
	DEVECHO	"EF: IO="
	DEVECHO	EF_BASE
	DEVECHO	"\n"
;
;======================================================================
; VDU DRIVER - INITIALIZATION
;======================================================================
;
EF_INIT:
;
	LD IY,EF_IDAT			; POITER TO INSTANCE DATA
;
	CALL	NEWLINE			; FORMATTING
	PRTS("EF : IO=0x$")
	LD	A,EF_BASE
	CALL	PRTHEXBYTE

	PRTS(" MODE=$")			; OUTPUT DISPLAY FORMAT
	LD	A,EF_DROWS
	CALL	PRTDECB
	PRTS("X$")
	LD	A,EF_DLINES
	CALL	PRTDECB

	CALL	EF_PROBE		; CHECK FOR HW EXISTENCE
	JR	Z,EF_INIT1		; CONTINUE IF HW PRESENT
;
	PRTS(" NOT PRESENT$")
	XOR	A
	OR	-8			; HARDWARE NOT PRESENT
	RET
;
EF_INIT1:
	OUT (EF_RESET),A		; HARDWARE RESET
;
	LD	A,EF_DIST0
	LD	(EF_CON_BANKY),A		;
;
	CALL 	EF_CRTINIT		; INIT EF9345 CHIP
;
; ADD OURSELVES TO VDA DISPATCH TABLE
	LD	BC,EF_FNTBL		; BC := FUNCTION TABLE ADDRESS
 	LD	DE,EF_IDAT		; DE := VDU INSTANCE DATA PTR
	CALL	VDA_ADDENT		; ADD ENTRY, A := UNIT ASSIGNED
;
#IF TERMENABLE
	; INITIALIZE EMULATION
	LD	C,A			; ASSIGNED VIDEO UNIT IN C
	LD	DE,EF_FNTBL		; DE := FUNCTION TABLE ADDRESS
	LD	HL,EF_IDAT		; HL := VDU INSTANCE DATA PTR
	CALL	TERM_ATTACH		; DO IT
#ENDIF
;
	XOR	A			; SIGNAL SUCCESS
	RET
;
EF_CRTINIT:
	LD	DE,(EF_R0+EF_EXEC)*256 + EF_NOP	; FORCE NOP
	CALL	EF_WWRREG
;
	LD	HL,EF_INIT9345		; INITIAL SETUP PARAMETERS
	CALL	EF_LOAD_MODE
;
	LD	DE,0
	LD	(EF_VDA_OFFSET),DE
;
#IF (EF_SIZE = V40X24)
	XOR	A
	LD	(EF_VDATYPESET),A
#ENDIF
;
; E = CHARACTER ATTRIBUTES : E0 = BLINK, E1 = UNDELINE, E2 = REVERSE, E3  = COLOR SET
; VIDEO SET CHARACTER ATTRIBUTE FOR SCROLL, KRL, ETC.
	LD	E,00000000B
	CALL	EF_VDASAT
;
	LD	E,EF_BG_BLACK + EF_FG_WHITE	; SET CHARACTER COLOR
	CALL	EF_VDASCO
;
; VIDEO SET CURSOR STYLE
; ENTRY: C = VIDEO UNIT, D = START/END, E = STYLE : E0 = BLINK/FLASH, E1 = UNDELINE, E2 = REVERSE/COMPLEMENT
; MAT5 = 1 : FLASH, MAT4 = 0 : COMPLEMENT
; RETURN A = STATUS
	LD	E,3				; UNDERLINED BLINKING
	CALL	EF_VDASCS
;
	CALL	EF_CLEARALL
;
	LD	DE,0				; SET CURSOR TO 0,0
	CALL	EF_VDASCP
	RET
;
EF_CLEARALL:
	LD	DE,0				; SET CURSOR 0,0
	CALL	EF_VDASCP			; D = ROW, E = COLUMNS
	LD	HL,EF_DROWS * EF_DLINES
;
	LD	E,' '
	CALL	EF_VDAFIL
	XOR	A
	RET
;
; R1 := C BYTE IS THE CHARACTER CODE
; R2 := B BYTE TYPE AND SET, OTHER PARAMETERS
; R3 := A BYTE ATTRIBUTES, NEGATIVE, FG COLOR, FLASH, BG COLOR
;
#IF (EF_SIZE=V80X24)
EF_KRL80:
	PUSH	DE
	LD	DE,EF_R0*256 + EF_KRL	; R0 KRL COMMAND
	CALL	EF_WWRREG
	LD	D,EF_R3
	LD	A,(EF_VDAATTR)		; DOUBLE ATTRIBUTES FOR LOWER NIBBLE
	LD	E,A
	CALL	EF_WWRREG
	POP	DE
	RET
#ENDIF
;
#IF (EF_SIZE = V40X24)
EF_KRF40:
	PUSH	DE
	LD	DE,EF_R0*256 + KRF
	CALL	EF_WWRREG
	LD	D,R3
	LD	A,(EF_VDACOLOR)
	LD	B,A
	LD	A,(EF_VDAATTR)
	OR	B
	LD	E,A				; COLOR
	CALL	EF_WRREG
	LD	D,EF_R2
	LD	A,(EF_VDATYPESET)
	LD	E,A
	CALL	EF_WRREG
	POP	DE
	XOR	A
	RET
#ENDIF
;
;----------------------------------------------------------------------
; PROBE FOR EF9345 HARDWARE
;----------------------------------------------------------------------
;
; ON RETURN, ZF SET INDICATES HARDWARE FOUND
;
EF_PROBE:
	LD	DE,EF_R1*256+'a'
	LD	H,E
	CALL	EF_WRREG
	CALL	EF_RDREG
	CP	H
	RET
;
;----------------------------------------------------------------------
; WAIT FOR VDU TO BE READY FOR A DATA READ/WRITE
;----------------------------------------------------------------------
;
EF_WAITRDY:
	LD	A,EF_R0
	OUT	(EF_SETREG),A
	IN	A,(EF_DATAACC)
	RLA
	JR	C,EF_WAITRDY
	RET
;
;----------------------------------------------------------------------
; UPDATE EF9345 REGISTERS
;   EF_WRREG WRITES VALUE IN E TO EF9345 REGISTER SPECIFIED IN D
;	EF_WWRREG AFTER WAITING FOR READY WRITES VALUE IN E TO EF9345 REGISTER SPECIFIED IN D
;-------------------------------------------------------------------	--
;
EF_WWRREG:
	CALL	EF_WAITRDY
EF_WRREG:
	LD	A,D
	OUT	(EF_SETREG),A
	LD	A,E
	OUT	(EF_DATAACC),A
	RET
;
;----------------------------------------------------------------------
; READ EF9345 REGISTERS
;   EF_RDREG READS EF9345 REGISTER SPECIFIED IN D AND RETURNS VALUE IN A AND E
;----------------------------------------------------------------------
EF_RDREG:
	CALL	EF_WAITRDY
	LD	A,D
	OUT	(EF_SETREG),A
	IN	A,(EF_DATAACC)
	LD	E,A
	RET
;
;----------------------------------------------------------------------
; READ INDIRECT EF9345 REGISTERS
;   EF_READ_INDIR READS EF9345 REGISTER SPECIFIED IN D AND RETURNS VALUE IN A AND E
;----------------------------------------------------------------------
;
EF_READ_INDIR:
	LD	A,EF_IND
	OR	D
	OR	EF_RREG
	LD	E,A
	LD	D,EF_R0 + EF_EXEC
	CALL	EF_WWRREG
	LD	D,EF_R1
	CALL	EF_RDREG
	RET
;
;----------------------------------------------------------------------
; WRITES INDIRECT EF9345 REGISTERS
;   EF_LOAD_INDIR WRITES VALUE IN E TO INDIRECT EF9345 REGISTER SPECIFIED IN D
;----------------------------------------------------------------------
;
EF_LOAD_INDIR:				; D = TARGET REGISTER, E = VALUE TO WRITE
	PUSH	DE
	LD	D,EF_R1
	CALL	EF_WWRREG
	POP	DE
	PUSH	DE
	LD	A,EF_IND
	OR	D
	LD	E,A
	LD	D,EF_R0 + EF_EXEC
	CALL	EF_WWRREG
	POP	DE
	RET
;
EF_LOAD_MODE:				; LOAD MODE
	LD	D,EF_TGSREG		; START INDIRECT REGISTER 1 : TGS
	LD	B,EF_INIT_CNT		; LOAD 5 INDIRECT REGISTERS
EF_MODEREG:
	LD	E,(HL)
	CALL	EF_LOAD_INDIR
	INC	HL
	INC	D
	LD	A,EF_INIT_CNT
	CP	D
	JR	NZ,EF_NOSKIP
	INC	D
	INC	D
	LD	E,(HL)
	LD	A,(EF_CON_BANKY)
	ADD	A,E
	LD	E,A
	CALL	EF_LOAD_INDIR
	RET
EF_NOSKIP:
	DJNZ	EF_MODEREG
	RET
;
EF_GETXY:				; D = ROW, E = COLUMNS
	CALL	EF_GETX
	CALL	EF_GETY
	RET
;
EF_GETX:				; E = COLUMNS
	CALL	EF_WAITRDY
	LD	D,EF_XP
	CALL	EF_RDREG
#IF (EF_SIZE=V80X24)
	RLCA				; CORRECTION 80 ROWS MODE
#ENDIF
	LD	E,A
	RET
;
EF_GETY:				; D = ROW
	CALL	EF_WAITRDY
	PUSH	DE
	LD	D,EF_YP
	CALL	EF_RDREG
	AND	00011111B
	PUSH	HL
	LD	HL,(EF_VDA_OFFSET)
	SUB	H
	POP	HL
	SUB	FIRSTLINE
	POP	DE
	LD	D,A
	RET
;
EF_LOADFONTS:
	PRTS("Not implemented$")
	CALL	NEWLINE
	SYSCHKERR(ERR_NOTIMPL)		; NOT IMPLEMENTED (YET)
	LD	A,-2
	OR	A
	RET
;
EF_NOTIMP:
	PRTS("Not implemented$")
	CALL	NEWLINE
	SYSCHKERR(ERR_NOTIMPL)		; NOT IMPLEMENTED (YET)
	XOR	A
	OR	-2			; FUNCTION NOT IMPLEMENTED
	RET
;
EF_CURSORON:				; CURSOR DISPLAY ENABLE
	PUSH	DE
	PUSH	AF
	LD	D,EF_MATREG		; LOAD CURSOR ENABLE
	CALL	EF_READ_INDIR
	OR	01000000B
	LD	D,EF_MATREG		; SET CURPOS ENABLE
	LD	E,A
	CALL	EF_LOAD_INDIR
	POP	AF
	POP	DE
	RET
;
EF_CURSOROFF:
	PUSH	DE
	PUSH	AF
	LD	D,EF_MATREG		; LOAD CURSOR ENABLE
	CALL	EF_READ_INDIR
	AND	10111111B
	LD	D,EF_MATREG		; SET CURSOR ENABLE
	LD	E,A
	CALL	EF_LOAD_INDIR
	POP	AF
	POP	DE
	RET
;
EF_INCCURSOR:				; CURSOR POSITION, D = ROW, E = COLUMN
; Y , X WITH	MODULO DROWS
	PUSH	DE
	PUSH	HL
	LD	HL,(EF_VDA_OFFSET)
	LD	DE,(EF_VDA_POS)
	ADD	HL,DE
	INC	DE
	LD	A,EF_DROWS
	CP	E
	JR	NZ,EF_CURS0
	LD	E,0
	INC	D
	LD	A,EF_DLINES
	CP	D
	JR	NZ,EF_CURS0
;	LD	D,0
	DEC	D			; Y REMAINS INSIDE THE BOUNDARY
	LD	(EF_VDA_POS),DE
	CALL	EF_VDASCP
	POP	HL
	POP	DE
	OR	-6			; PARAMETER OUT OF RANGE
	RET
EF_CURS0:
	LD	(EF_VDA_POS),DE
	CALL	EF_VDASCP
	POP	HL
	POP	DE
	RET
;
;----------------------------------------------------------------------
;  DISPLAY CONTROLLER CHIP INITIALIZATION
;----------------------------------------------------------------------
;
EF_INIT9345:
#IF (EF_SIZE=V80X24)		; E)
EF_TGS:	.DB 11000010b		; 80 char/row, long char code (12 bits) : TGS Register interlaced
EF_MAT:	.DB EF_CSTY		; 01001000b		; cursor enabled, fixed complent cursor, margin color = black : MAT Register
EF_PAT:	.DB 01111110b		; 80 char/row, long code, upper/lower bulk on, conceal on,
				; I high during active disp. area, status row disebled : PAT Register
EF_DOR:	.DB 10001111b		; DOR(3:0) = 1111   : color c0 = white, DOR(7:4) = 1000 : color c1 = black
EF_ROR:	.DB 00001000b		; ROR(7:5) =   000  : displayed page memory starts from block 0
				; ROR(4:0) = 01000 : origin row = 8
#ENDIF
;
#IF (EF_SIZE=V40X24)
EF_TGS:	.DB 00000000B		; 40 char/row, long char code (24 bits) : TGS Register interlaced
EF_MAT:	.DB EF_CSTY		; 01001100B cursor enabled, fixed complent cursor, margin color = black : MAT Register
EF_PAT:	.DB 01111110B		; 40 char/row, long code, upper/lower bulk on, conceal on,
				; I high during active disp. area, status row disebled : PAT Register
; DOR register initialization
;
; DOR(3:0) = 0011 : alpha UDS slices in block 3
; DOR(6:4) = 001 : semigraphic uds slices in block 2 and 3
; DOR 7 = 0 : Quadrichrome slices from block 0
EF_DOR:	.DB 0		;
EF_ROR:	.DB 00001000B		; ROR(7:5) =   000  : displayed page memory starts from block 0
				; ROR(4:0) = 01000 : origin row = 8
#ENDIF

EF_INIT_CNT:	.EQU	$ - EF_INIT9345
;
;======================================================================
; EF9345 DRIVER - VIDEO DISPLAY ADAPTER FUNCTIONS
;======================================================================
;
EF_FNTBL:
	.DW	EF_VDAINI
	.DW	EF_VDAQRY
	.DW	EF_VDARES
	.DW	EF_VDADEV
	.DW	EF_VDASCS
	.DW	EF_VDASCP
	.DW	EF_VDASAT
	.DW	EF_VDASCO
	.DW	EF_VDAWRC
	.DW	EF_VDAFIL
	.DW	EF_VDACPY
	.DW	EF_VDASCR
	.DW	EF_NOTIMP		; PPK_STAT
	.DW	EF_NOTIMP		; PPK_FLUSH
	.DW	EF_NOTIMP		; PPK_READ
	.DW	EF_VDARDC
#IF (($ - EF_FNTBL) != (VDA_FNCNT * 2))
	.ECHO	"*** INVALID VDU FUNCTION TABLE ***\n"
#ENDIF
;
EF_VDAINI:
; VIDEO INITIALIZE
; FULL REINITIALIZATION, CLEAR SCREEN, CURRENTLY IGNORES VIDEO MODE AND BITMAP DATA
	PUSH	HL
	CALL	EF_INIT1
	POP	HL
	LD	A,L
	OR	H
	CALL	NZ,EF_LOADFONTS

	CALL	EF_CLEARALL
	CALL	EF_LOADCSTYLE
	LD	DE,0
	LD	(EF_VDA_OFFSET),DE
	CALL	EF_VDASCP

	XOR	A
	RET
;
EF_VDAQRY:
; VIDEO QUERY
; ENTRY: C = VIDEO UNIT, HL = FONT BITMAT
; RETURN: C = VIDEO MODE, D = ROWS, E = COLUMNS, HL = FONT BITMAT
	LD	C,$00			; MODE ZERO IS ALL WE KNOW
	LD	D,EF_DLINES
	LD	E,EF_DROWS
	LD	HL,0			; EXTRACTION OF CURRENT BITMAP DATA NOT SUPPORTED
	XOR	A			; SIGNAL SUCCESS
	RET
;
EF_VDARES:
; VIDEO RESET
; SOFT RESET
;
	XOR	A
	RET
;
EF_VDADEV:
; VIDEO DEVICE
; ENTRY: C = VIDEO UNIT
; RETURN: D := DEVICE TYPE, E := DEVICE NUMBER, H := DEVICE UNIT MODE, L := DEVICE I/O BASE ADDRESS
	LD	DE,(VDADEV_EF * 256) + 0	; D := DEVICE TYPE
						; E := PHYSICAL UNIT IS ALWAYS ZERO
	LD	HL,EF_BASE			; H INDICATES THE VARIANT OF THE CHIP OR CIRCUIT, H = 0 : NO VARIANTS
						; L := BASE I/O ADDRESS
	XOR	A				; SIGNAL SUCCESS
	RET
;
EF_VDASCS:
; VIDEO SET CURSOR STYLE
; ENTRY: C = VIDEO UNIT, D = START/END, E = STYLE : E0 = BLINK/FLASH, E1 = UNDELINE, E2 = REVERSE/COMPLEMENT
; MAT5 = 1 : FLASH, MAT4 = 0 : COMPLEMENT
; RETURN A = STATUS
	XOR	A
	SRA	E
	JR	NC,EF_VDASCS0
	OR	EF_BLINK		; CURSOR IS BLINKING
EF_VDASCS0:
	SRA	E
	JR	NC,EF_VDASCS1
	OR	EF_ULIN			; UNDERLINED CURSOR
	JR	EF_VDASCS2
EF_VDASCS1:
	SRA	E
	JR	NC,EF_VDASCS2
	AND	EF_COMPL
EF_VDASCS2:
	LD	(EF_VDACATTR),A
	CALL	EF_LOADCSTYLE
	XOR	A
	RET
;
EF_VDASCP:
; SET VIDEO CURSOR POSITION
; ENTRY: C = VIDEO UNIT, D = ROW, E = COLUMN
; RETURN A = STATUS
; CHECKING THE FEASIBILITY OF THE INPUT VALUES
	LD	A,EF_DLINES-1
	CP	D
	JR	C,EF_VDASCP0
	LD	A,EF_DROWS-1
	CP	E
	JR	C,EF_VDASCP0
	LD	(EF_VDA_POS),DE		; D = ROW, E = COLUMNS
;
	PUSH	DE
#IF (EF_SIZE=V80X24)
	RRC	E			; ADJUST TO 80 COLUMN LAYOUT
#ENDIF
	LD	D,EF_XP			; X POSITION
	CALL	EF_WWRREG
	POP	DE
;
	PUSH	HL
	LD	HL,(EF_VDA_OFFSET)
	LD	A,H
	POP	HL
;
	ADD	A,FIRSTLINE
	ADD	A,D
	CP	FIRSTLINE+EF_DLINES
	JR	C,EF_SETYP0
	SUB	EF_DLINES
EF_SETYP0:
	LD	E,A
	LD	A,(EF_CON_BANKY)	; STAY IN DISTRICT
	OR	E
	LD	E,A
	LD	D,EF_YP
	CALL	EF_WWRREG
	XOR	A
	RET
EF_VDASCP0:
	XOR	A
	OR	-6			; PARAMETERS OUT OF RANGE $FF
	RET
;
EF_VDASAT:
; VIDEO SET CHARACTER ATTRIBUTE FOR SCROLL, KRL, ETC.
; ENTRY: C = VIDEO UNIT, E = ATTRIBUTE
; 80 CHARACTER/ROW STYLE := E0 = BLINK, E1 = UNDELINE, E2 = REVERSE, E3 = COLOR SELECT
; 40 CHARACTER/ROW STYLE := E0 = BLINK, E1 = UNDELINE, E2 = REVERSE, E3 = COLOR SELECT, E4..E7 = TYPE AND SET
; B(0)		:= INSERT
; B(1)		:= DOUBLE HIGHT
; B(2)		:= concealed character appears as a space on the screen
; B(3)		:= DOUBLE WIDTH
; B(4..7) 	:= TYPE AND SET
; RETURN A = STATUS
#IF (EF_SIZE=V80X24)
	XOR	A
	SRA	E			; IS BLINKING
	JR	NC,EF_VDASAT0
	OR	EF_FLASH
EF_VDASAT0:
	SRA	E
	JR	NC,EF_VDASAT1
	OR	EF_UNDERLINE		; UNDERLINED CURSOR
EF_VDASAT1:
	SRA	E
	JR	NC,EF_VDASAT
	OR	EF_NEGATIVE		; NEGATIVE CURSOR
EF_VDASAT2:
	SRA	E
	JR	NC,EF_VDASAT3
	OR	EF_COLORSET
EF_VDASAT3:
#ENDIF
#IF (EF_SIZE=V40X24)
; set VDATYPESET
	LD	A,E
	AND	$F0
	LD	(EF_VDATYPESET),A
	XOR	A
	SRA	E			; IS BLINKING
	JR	NC,EF_VDASAT0
	OR	EF_FLASHCHAR
EF_VDASAT0:
	SRA	E
	SRA	E
	JR	NC,EF_VDASAT1
	OR	EF_REVERSCHAR
EF_VDASAT1:
#ENDIF
	LD	(EF_VDAATTR),A
	XOR	A
	RET
;
EF_LOADCSTYLE:
	LD	A,(EF_VDACATTR)
	LD	B,A
	LD	D,EF_MATREG
	CALL	EF_READ_INDIR
	AND	11001111B
	OR	B
	LD	E,A
	LD	D,EF_MATREG
	CALL	EF_LOAD_INDIR
	RET
;
EF_VDASCO:
; VIDEO SET CHARACTER COLOR
; ENTRY C = VIDEO UNIT, E = COLOR
; RETURN A = STATUS
	CALL	EF_WAITRDY
#IF (EF_SIZE=V80X24)	; COLOR SETUP USE MARGIN COLOR IN MAT AND
	LD	A,E
	LD	B,A			; B = BG
	SRL	B
	SRL	B
	SRL	B
	SRL	B
	AND	$F8			; MASK BG COLOR
	LD	A,E
	AND	$07			; MASK FG COLOR
	LD	C,A			; C = FG
	LD	D,EF_DORREG		; LOAD FG COLOR FROM DOR(3..0)
	CALL	EF_READ_INDIR
	AND	$F8
	OR	C			; SET NEW FG COLOR
	LD	E,A
	LD	D,EF_DORREG		; LOAD NEW FG COLOR
	CALL	EF_LOAD_INDIR
;
	LD	D,EF_MATREG		; LOAD BG COLOR
	CALL	EF_READ_INDIR
	AND	$F8			; MASK BG COLOR
	OR	B			; SET NEW BG COLOR
	LD	E,A
	LD	D,EF_MATREG		; LOAD NEW BG COLOR
	CALL	EF_LOAD_INDIR
#ENDIF
#IF (EF_SIZE=V40X24)
	LD	HL,EF_VDACOLOR
	LD	A,E
	AND	$7			; MASK FG COLOR
	RLD
	LD	A,E
	SRL	A			; BG COLOR TO LOW ORDER FOUR BITS
	SRL	A
	SRL	A
	SRL	A
	RLD
#ENDIF
	XOR A
	RET
;
EF_VDAWRC:
; VIDEO WRITE CHARACTER,
; ENTRY C = VIDEO UNIT, E = CHARACTER
; RETURN A = STATUS
#IF (EF_SIZE=V80X24)
	CALL	EF_KRL80
	LD	D,EF_R1+EF_EXEC
	CALL	EF_WWRREG
#ENDIF
#IF (EF_SIZE=V40X24)
	CALL	EF_KRF40
	LD	D,EF_R1+EF_EXEC
	CALL	EF_WWRREG
#ENDIF
	CALL	EF_INCCURSOR
	XOR	A
	RET
;
EF_VDAFIL:
; VIDEO FILL
; ENTRY: C = VIDEO UNIT, E = CHARACTER, HL = COUNT OF CHARACTERS
; RETURN A = STATUS
	CALL	EF_CURSOROFF
EF_VDAFIL0:
	CALL	EF_VDAWRC
	DEC	HL
	LD	A,H
	OR	L
	JR	NZ,EF_VDAFIL0
	CALL	EF_CURSORON
	XOR	A
	RET
;
EF_VDACPY:
; VIDEO COPY
; ENTRY C = VIDEO UNIT, D = SOURCE ROW, E =  SOURCE COLUMN, L = COUNT
; RETURN A = STATUS
	PUSH	DE			; SAVE SOURCE
	LD	A,L
	LD	(EF_CPYCNT),A
	CALL	EF_CURSOROFF
	CALL	EF_GETXY		; GET AND SAVE CURRENT CURSOR POSITION
	LD	(EF_CURPOS),DE
; CHECK END OF SCREEN
	LD	H,D			; D = CURRENT LINE
	LD	E,EF_DROWS		; CHARACTERS IN ROW
	CALL	MULT8			; LINES * DROWS
	POP	DE
	PUSH	DE
	LD	D,0
	ADD	HL,DE			; ADD CHARACTERS IN CURRENT LINE := USED CHARACTERS
	EX	DE,HL
	LD	HL,EF_DLINES*EF_DROWS	; AVAILABLE CHARACTER COUNT
	XOR	A
	SBC	HL,DE			; REMAINING CHARACTERS = AVAILABLE - USED
	LD	C,L			; SAVE REMAINING CHARACTER COUNT
	LD	A,(EF_CPYCNT)
	LD	B,A
	LD	E,A
	LD	D,0
	SBC	HL,DE			; COMPARE COPY COUNT WITH AVAILABLE
	JR	NC,EF_CPY0
	LD	B,C			; ADJUST COPY COUNT
EF_CPY0:
	POP	DE
	CALL	EF_VDASCP		; SET SOURCE AS CURSOR
	LD	HL,EF_BUF
	PUSH	BC
EF_CPYRD:
#IF (EF_SIZE=V80X24)
	PUSH	BC
	CALL	EF_VDARDC
	POP	BC
	LD	(HL),E
	INC	HL
#ENDIF
#IF (EF_SIZE=V40X24)
	PUSH	HL
	PUSH	BC
	CALL	 EF_VDARDC
	LD	A,L
	POP	BC
	POP	HL
	LD	(HL),E
	INC	HL
	LD	(HL),A
	INC	HL
#ENDIF
	CALL	EF_INCCURSOR
	DJNZ	EF_CPYRD
	LD	DE,(EF_CURPOS)		; RECOVER AND SET CURSOR POSITION
	CALL	EF_VDASCP
	POP	BC
	LD	HL,EF_BUF
EF_CPYWR:
#IF (EF_SIZE=V80X24)
	PUSH	BC
	LD	E,(HL)
	CALL	EF_VDAWRC
	INC	HL
	POP	BC
	DJNZ	EF_CPYWR
#ENDIF
#IF (EF_SIZE=V40X24)
	PUSH	BC
	LD	E,(HL)
	INC	HL
	PUSH	HL
	LD	L,(HL)
	CALL	EF_VDAWRC
	POP	HL
	INC	HL
	POP	BC
	DJNZ	EF_CPYWR
#ENDIF
	; RESTORE CURSOR
	LD	DE,(EF_CURPOS)
	CALL	EF_VDASCP
	CALL	EF_CURSORON
	XOR	A
	RET
;
EF_VDASCR:
; VIDEO SCROLL
; ENTRY: C = VIDEO UNIT, E = LINES
; RETURN A = STATUS
	CALL	EF_CURSOROFF
EF_VDASCR0:
	LD	A,E
	OR	A
	JR	Z,EF_VDASCR2		; SCROLL 0, NOTHING TO DO
	PUSH	DE
	RLCA
	JR	C,EF_VDASCR1
	CALL	EF_SCRUP
	POP	DE
	DEC	E
	JR	EF_VDASCR0
EF_VDASCR1:
	CALL	EF_SCRDOWN
	POP	DE
	INC	E
	JP	EF_VDASCR0
EF_VDASCR2:
	CALL	EF_CURSORON
	RET
;
EF_SCRUP:
	LD	HL,(EF_VDA_OFFSET)
	LD	DE,$0100 		; inc y
	ADD	HL,DE
	LD	A,H
	CP	EF_DLINES
	JR	NZ,EF_SCRUP0
	LD	HL,0
EF_SCRUP0:
	LD	(EF_VDA_OFFSET),HL
	LD	A,(EF_CON_BANKY)
	ADD	A,H
	ADD	A,FIRSTLINE
	LD	E,A
	LD	D,EF_RORREG
	CALL	EF_LOAD_INDIR
; fill exposed line
	LD	HL,(EF_VDA_POS)
	PUSH	HL
	LD	HL,(EF_DLINES-1)*256
	EX	DE,HL
EF_SCRCLEAR:
	CALL	EF_VDASCP
	LD	E,' '
	LD	HL,EF_DROWS
	CALL	EF_VDAFIL
;
	POP	HL
	EX	DE,HL
	CALL	EF_VDASCP
	RET
;
EF_SCRDOWN:
	XOR	A
	LD	HL,(EF_VDA_OFFSET)
	LD	DE,$FF00
	ADD	HL,DE
	LD	A,$FF
	CP	H
	JR	NZ,EF_SCRDOWN0
	LD	H,EF_DLINES-1
EF_SCRDOWN0:
	LD	(EF_VDA_OFFSET),HL
	LD	A,(EF_CON_BANKY)
	ADD	A,FIRSTLINE
	ADD	A,H
	LD	E,A
	LD	D,EF_RORREG
	CALL	EF_LOAD_INDIR
; fill exposed line
	LD	HL,(EF_VDA_POS)
	PUSH	HL
	LD	DE,0
;	JR	EF_SCRCLEAR
	CALL	EF_VDASCP
	LD	E,' '
	LD	HL,EF_DROWS
	CALL	EF_VDAFIL
;
	POP	HL
	EX	DE,HL
	CALL	EF_VDASCP
	RET
;
EF_VDARDC:
; READ CHARACTER AT CURRENT VIDEO POSITION
; ENTRY: C = VIDEO UNIT
; RETURN: A = STATUS, E = CHARACTER, B = CHARACTER COLOR, C = CHARACTER ATTRIBUTES, L = CHARACTER TYPESET, 40X24 ONLY
#IF (EF_SIZE = V80X24)
	LD	D,EF_R0
	LD	A,EF_KRL		; R0 KRL COMMAND NO AUTOINC
	OR	EF_RREG
	LD	E,A
	CALL	EF_WWRREG
	LD	D,EF_R3 + EF_EXEC	; READ ATTRIBUTES
	CALL	EF_RDREG
	LD	C,A
	CALL	EF_WAITRDY
	LD	D,EF_R1+EF_EXEC
	CALL	EF_RDREG
	PUSH	DE
; READ COLOR
	LD	D,EF_DORREG		; LOAD FG COLOR
	CALL	EF_READ_INDIR
	AND	$07
	LD	B,A
	LD	D,EF_MATREG		; LOAD BG COLOR
	CALL	EF_READ_INDIR
	RLCA
	RLCA
	RLCA
	RLCA
	AND	$70
	OR	B
	LD	B,A
	POP	DE
	XOR	A
;	LD	L,A
	RET
#ENDIF
#IF (EF_SIZE = V40X24)
	LD	D,R0
	LD	A,KRF			; R0 KRL COMMAND NO AUTOINC
	OR	EF_RREG
	LD	E,A
	CALL	EF_WWRREG
	LD	D,EF_R3 + EF_EXEC	; READ CHARACTER ATTRIBUTES
	CALL	EF_RDREG
	AND	$77
	LD	B,A
	RLC	B
	RLC	B
	RLC	B
	RLC	B
	LD	A,E
	AND	$88
	LD	C,A
	LD	D,EF_R2 + EF_EXEC	; READ CHARACTER TYPESET
	CALL	EF_RDREG
	LD	L,A
	LD	D,EF_R1+EF_EXEC		; READ CHARACTER
	CALL	EF_RDREG
	XOR	A
	RET
#ENDIF
;
EF_IDAT:
	.DB	KBDMODE_NONE	; PS/2 8242 KEYBOARD CONTROLLER
	.DB	0
	.DB	0
;
EF_VDA_POS	.DW	0
EF_CURPOS	.DW	0
EF_CPYCNT	.DB	0
EF_VDA_OFFSET	.DW	0
EF_CON_BANKY	.DB	0
EF_VDAATTR	.DB	0		; CHARACTER ATTRIBUTES
EF_VDACATTR	.DB	0		; CURSOR ATTRIBUTES
EF_VDACOLOR	.DB	0		; CHARACTER COLOR
#IF (EF_SIZE = V40X24)
EF_VDATYPESET	.DB	0		; 40 CHAR/ROW PARAMETER
#ENDIF
EF_BUF:
#IF (EF_SIZE = V80X24)
	.FILL	EF_DLINES*EF_DROWS	;256,0	; COPY BUFFER
#ENDIF
#IF (EF_SIZE = V40X24)
	.FILL 2*EF_DLINES*EF_DROWS	;512,0
#ENDIF
