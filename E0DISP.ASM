;----- Display one editor string ----------

;include E0DISP.MAC
;include RK86.MAC
IFNDEF	CURSM
extrn CURSM
EXTRN	DISP_ADR, DMA_ADR, VRAM_ADR
ENDIF

SETSCR::
IFDEF VDP9918
T_T80_VRAM_COLOR_ADDRESS	EQU	0A00h
T_T80_VRAM_NAME_ADDRESS		EQU	0000h
T_T80_VRAM_PATT_ADDRESS		EQU	2000h
T_REG_0			EQU	0
T_REG_1			EQU	1
T_REG_2			EQU	2
T_REG_3			EQU	3
T_REG_4			EQU	4
T_REG_5			EQU	5
T_REG_6			EQU	6
T_REG_7			EQU	7
T_NUM_REGISTERS		EQU	8
T_REG_NAME_TABLE	EQU	T_REG_2
T_REG_COLOR_TABLE	EQU	T_REG_3
T_REG_PATTERN_TABLE	EQU	T_REG_4
T_REG_SPRITE_ATTR_TABLE	EQU	T_REG_5
T_REG_SPRITE_PATT_TABLE	EQU	T_REG_6
T_REG_FG_BG_COLOR	EQU	T_REG_7

T_R0_MODE_GR_I		EQU	00
T_R0_MODE_GR_II		EQU	02
T_R0_MODE_MULTICOLOR	EQU	00
T_R0_MODE_TEXT		EQU	00
T_R0_MODE_TEXT80	EQU	04
T_R0_MODE_TEXT8_80	EQU	80h
T_R0_EXT_VDP_ENABLE	EQU	01
T_R0_EXT_VDP_DISABLE	EQU	00

T_R1_RAM_16K		EQU	80h
T_R1_RAM_4K		EQU	00
T_R1_DISP_BLANK		EQU	00
T_R1_DISP_ACTIVE	EQU	40h
T_R1_INT_ENABLE		EQU	20h
T_R1_INT_DISABLE	EQU	00
T_R1_MODE_GRAPHICS_I	EQU	00
T_R1_MODE_GRAPHICS_II	EQU	00
T_R1_MODE_MULTICOLOR	EQU	08
T_R1_MODE_TEXT		EQU	10h
T_R1_SPR_8		EQU	00
T_R1_SPR_16		EQU	02
T_R1_SPR_MAG1		EQU	00
T_R1_SPR_MAG2		EQU	01
T_TRANSPARENT		EQU	0
T_BLACK			EQU	1
T_MED_GREEN		EQU	2
T_LT_GREEN		EQU	3
T_DK_BLUE		EQU	4
T_LT_BLUE		EQU	5
T_DK_RED		EQU	6
T_CYAN			EQU	7
T_MED_RED		EQU	8
T_LT_RED		EQU	9
T_DK_YELLOW		EQU	10
T_LT_YELLOW		EQU	11
T_DK_GREEN		EQU	12
T_MAGENTA		EQU	13
T_GREY			EQU	14
T_WHITE			EQU	15


T_InitialiseText80:
IFNDEF	MsX
	RET
ELSE
	;CALL	T_Reset
	MVI	A,0
	PUSH	PSW


; non-bitmap color and pattern table configuration
	MVI	B, T_REG_COLOR_TABLE
	MVI	C, T_T80_VRAM_COLOR_ADDRESS / 40h
	CALL	T_WriteRegValue

	; set up pattern table address (register = address / 800H)
	MVI	B, T_REG_PATTERN_TABLE
	MVI	C, T_T80_VRAM_PATT_ADDRESS / 800h
	CALL	T_WriteRegValue

	; set up name table address (register = address / 400H)
	MVI	B, T_REG_NAME_TABLE
IFDEF	MSX
	MVI	C, (T_T80_VRAM_NAME_ADDRESS / 400h) AND 7Ch OR 3 
ELSE
	MVI	C, (T_T80_VRAM_NAME_ADDRESS / 400h) AND 0fh;7Ch OR 3 
ENDIF
	CALL	T_WriteRegValue

	LXI	H, T_T80_VRAM_PATT_ADDRESS ; load font from address in bc
	CALL	T_SetAddrWriteHL

	POP	PSW
	CPI	80H
	JZ	font16


	LXI	H,FONTFILNAM
	LXI	D,FCB
	CALL	GTFNAM

	LXI	H, TXTBUFF
	PUSH	H
	CALL	RDBOD
	POP	H

	;LXI	H, tmsFont8
	LXI	D, 2048;tmsFont8End - tmsFont8
	CALL	T_WriteBytes

	LXI	B, (T_REG_0 SHL 8) OR T_R0_EXT_VDP_DISABLE OR T_R0_MODE_TEXT80
	CALL	T_WriteRegValue
	JMP	Reg0Ok

font16:
	;LXI	H, tmsFont
	;LXI	D, tmsFontEnd - tmsFont ; tmsFontBytes
	;CALL	T_WriteBytes

	LXI	B, (T_REG_0 SHL 8) OR T_R0_EXT_VDP_DISABLE OR T_R0_MODE_TEXT80 OR T_R0_MODE_TEXT8_80
	CALL	T_WriteRegValue

reg0ok:
	LXI	B, (T_REG_1 SHL 8) OR T_R1_MODE_TEXT OR T_R1_DISP_ACTIVE OR T_R1_INT_ENABLE
	CALL	T_WriteRegValue

	LXI	B, (T_REG_FG_BG_COLOR SHL 8) OR T_DK_GREEN OR (T_WHITE SHL 4)
	;JMP	T_WriteRegValue

; C - value
; B - reg
T_WriteRegValue:
	DI
	MOV	A,C
	OUT	VDP+1
	MOV	A,B
	ORI	80H
	OUT	VDP+1
	;EI
	RET

T_WriteBytes:
	MOV	A,M
	OUT	VDP
	INX	H
	DCX	D
	MOV	A,D
	ORA	E
	JNZ	T_WriteBytes
	RET


FONTFILNAM:	DB	'font6x8.bin',0
ENDIF
ELSE
	LHLD	DISP_ADR
	INX	H
	;MVI	M,0
	PUSH	PSW
	XRA	A
	CALL	_out
	DCX	H

IFDEF	PALMIRA
	MVI	A,ScrWidth-1
	CALL	_out
	MVI	A,(ScrHeight+5-1)+40H
	CALL	_out
	MVI	A,0FFH
	CALL	_out
ELSE
	MVI	A,ScrWidth-1
	CALL	_out
	MVI	A,(ScrHeight+5-1)
	CALL	_out
	MVI	A,99H
	CALL	_out
ENDIF
	POP	PSW
	;mov	m,a
	CALL	_out

	INX	H
	MVI	A,27H
	CALL	_out
	;MOV	A,M
	CALL	_in
SETS01:
	;MOV	A,M
	CALL	_in
	ANI	20H
	JZ	SETS01

	;LXI	H,DMA+8
	LHLD	DMA_ADR
	PUSH	H
	PUSH	B
	LXI	B,0fh
	DAD	B
	POP	B
	CALL	_in
	POP	H
	INR	A
	JZ	VT37
	PUSH	B
	LXI	B,8
	DAD	B
	MVI	A,80H
	CALL	_out

	PUSH	H ; DMA+8
	;MVI	L,Low(DMA+4)
	DCR	L
	DCR	L
	DCR	L
	DCR	L
	XCHG
	LHLD	VRAM_ADR
	LXI	B,-ScrOffset
	DAD	B
	XCHG
	MOV	A,E
	CALL	_out
	MOV	A,D
	CALL	_out
	INX	H
	MVI	A,Low(ScrSize-1)
	CALL	_out
	MVI	A,High(ScrSize-1) or 40h
	CALL	_out
	;MVI	L,Low(DMA+8)
	POP	H ; DMA+8
	POP	B
	MVI	A,0A4H
	JMP	_out;RET
VT37:
	PUSH	B
	MOV	C,L
	MVI	A,0Dh
	ADD	C
	MOV	L,A
	XRA	A
	CALL	_out

	MVI	A,4
	ADD	C
	MOV	L,A
	XCHG
	LHLD	VRAM_ADR
	PUSH	B
	LXI	B,-ScrOffset
	DAD	B
	POP	B
	XCHG
	MOV	A,E
	CALL	_out
	MOV	A,D
	CALL	_out
	INX	H
	MVI	A,Low(ScrSize-1)
	CALL	_out
	MVI	A,High(ScrSize-1)
	CALL	_out

	MVI	A,0Bh
	ADD	C
	MOV	L,A
	MVI	A,1Ah
	CALL	_out

	MVI	A,8
	ADD	C
	MOV	L,A
	MVI	A,8
	CALL	_out

	MVI	A,0fh
	ADD	C
	MOV	L,A
	MVI	A,0Bh
	POP	B
	JMP	_out;	RET
ENDIF

IFDEF VDP9918
HideCursor:
	LDA	SYMSAVED
	ORA	A
	RZ
	PUSH	H
	LHLD	CURADDR
	CALL	T_SetAddrReadHL
	IN	VDP
	CPI	CursorSymbol
	JNZ	hc01
	CALL	T_SetAddrWriteHL
	LDA	CURSYM
	OUT	VDP
hc01:
	XRA	A
	STA	SYMSAVED
	POP	H
	RET
ENDIF

; Set cursor -
;	H - Y
;	L - X
; returns:
;	A = H - 1
SetCursor::
IFDEF VDP9918
IFDEF	MSX
	MVI	C,8
ELSE
	MVI	C, 16
ENDIF
	PUSH	H
	PUSH	D
	PUSH	B
	XCHG
	DCR	D
	DCR	E
	CALL	HideCursor
	MVI	A,1
	STA	SYMSAVED
	CALL	T_TextPos
	CALL	T_SetAddrReadHL
	IN	VDP
	STA	CURSYM
	SHLD	CURADDR
	;CPI	'2' ; No idea - when setting cursor on this symbol editor hangs - fixed by waiting for frame interrupt
	;JZ	sc05
	;CPI	'0'
	;JZ	sc05
	 PUSH	H
	MOV	L,A
	MVI	H,0
	DAD	H	; 2
	DAD	H	; 4
	DAD	H	; 8
	MOV	A,C
	CPI	8
	JZ	$+4
	DAD	H	; 16
	LXI	D, T_T80_VRAM_PATT_ADDRESS
	DAD	D
	CALL	T_SetAddrReadHL
	;MVI	B, 16
	MOV	B,C
	LXI	H, SYMBUF
	  PUSH	H
	CALL	T_ShortReadBytes

	MVI	A,8
	CMP	C
	LXI	H, T_T80_VRAM_PATT_ADDRESS + CursorSymbol * 8
	JZ	$+6
	LXI	H, T_T80_VRAM_PATT_ADDRESS + CursorSymbol * 16
	CALL	T_SetAddrWriteHL
	  POP	H
	IN	VDP+1
	ANI	80H
	JNZ	$-4
	MOV	B,C
	LDA	MODE
	CPI	0B3h
	JNZ	sc07
	MVI	A,8
	CMP	C
	JNZ	sc04
sc03:
	MOV	A,B
	CPI	3 + 1
	MOV	A,M
	JNC	$+4
	CMA
	OUT	VDP
	INX	H
	DCR	B
	JNZ	sc03
	JMP	sc01

sc04:
	MOV	A,B
	CPI	6 + 1
	MOV	A,M
	JNC	$+4
	CMA
	OUT	VDP
	INX	H
	DCR	B
	JNZ	sc04
	JMP	sc01
sc07:
	MOV	A,M
	CMA
	OUT	VDP
	INX	H
	DCR	B
	JNZ	sc07
sc01:
	 POP	H
sc05:
	CALL	T_SetAddrWriteHL
	MVI	a, CursorSymbol
	OUT	VDP
	POP	B
	POP	D
	POP	H
	MOV	A,H
	ADI	ScrYOffset-1
	RET

SYMBUF	EQU	STRBUF

;	HL - buffer address
;	DE - VRAM address
;	B  - number of bytes (1..256)
T_ShAddrWriteBytesDE:
	XCHG
	CALL	T_SetAddrWriteHL
	XCHG

T_ShortWriteBytes:
	MOV	A,M
	OUT	VDP
	INX	H
	DCR	B
	JNZ	T_ShortWriteBytes
	RET

T_ReadBytes:
	IN	VDP
	MOV	M,A
	INX	H
	DCX	D
	MOV	A,D
	ORA	E
	JNZ	T_ReadBytes
	RET

;	HL - buffer address
;	DE - VRAM address
;	B  - number of bytes (1..256)
T_ShAddrReadBytesDE:
	XCHG
	CALL	T_SetAddrReadHL
	XCHG

T_ShortReadBytes:
	IN	VDP
	MOV	M,A
	INX	H
	DCR	B
	JNZ	T_ShortReadBytes
	RET

T_SetAddrWriteHL:
	DI
	MOV	A,L
	OUT	VDP+1
	MOV	A,H
	ORI	40h
	OUT	VDP+1
	;EI
	RET
T_SetAddrReadHL:
	DI
	MOV	A,L
	OUT	VDP+1
	MOV	A,H
	OUT	VDP+1
	;EI
	RET

PRV_S:	PUSH	B
	LXI	B,-ScrWidth
	DAD	B
	POP	B
	RET

NXT_S:	PUSH	B
	LXI	B,ScrWidth
	DAD	B
	POP	B
	RET
; set the address to place text at X/Y coordinate
;	E = X
;	D = Y
T_TextPos:
	PUSH	D
	;MOV	A,E
	LDA	LPOS
	ADD	E
	MOV	E,D
	MVI	D, 0
	MOV	H,D
	MOV	L,E
	;DAD	D                       ; Y x 1
	DAD	H                       ; Y x 2
	DAD	H                       ; Y x 4
	DAD	D                       ; Y x 5
	DAD	H                       ; Y x 10
	DAD	H                       ; Y x 20
	DAD	H                       ; Y x 40
	DAD	H                       ; Y x 80
	MOV	E,A
	DAD	D                       ; add X for final address
	POP	D
	;LXI	D, T_T80_VRAM_NAME_ADDRESS       ; add name table base address
	;DAD	D
	RET
CURSYM:		DB	0
SYMSAVED:	DB	0
CURADDR:	DW	0
ELSE
	PUSH	D
	MVI	A,80H
	;STA	DISP+1
	XCHG
	LHLD	DISP_ADR
	INX	H
	;MOV	M,A
	CALL	_out
	DCX	H
	MOV	A,E
	PUSH	H
	LXI	H,LPOS
	ADD	M
	INX	H
	ADD	M
	POP	H
	DCR	A
	ADI	ScrXOffset
	;STA	DISP
	;MOV	M,A
	CALL	_out
	MOV	A,D
	ADI	ScrYOffset-1
	;STA	DISP
	;MOV	M,A
	CALL	_out
	POP	D
	RET
ENDIF

LPOS:	DB	0
;RK_END
@RK_END::
	DW	0
IFNDEF	noend
	END
ENDIF
