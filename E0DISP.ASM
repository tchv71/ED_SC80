;----- Display one editor string ----------

;include E0DISP.MAC
;include RK86.MAC
IFNDEF	CURSM
extrn CURSM
EXTRN	DISP_ADR, DMA_ADR, VRAM_ADR
ENDIF

SETSCR::
IFDEF VDP9918
T_T80_VRAM_PATT_ADDRESS		EQU	2000h
	MVI	A,80h
SetupCursor:
	PUSH	h
	PUSH	B
	CPI	80h
	JZ	s_c16
	LXI	H, T_T80_VRAM_PATT_ADDRESS + 255 * 8
	CALL	T_SetAddrWriteHL
	MVI	A, 255 - 3
	MVI	B, 8
	JMP	s_c01
s_c16:
	LXI	H, T_T80_VRAM_PATT_ADDRESS + 255 * 16;8
	CALL	T_SetAddrWriteHL
	MVI	A, 255 - 3
	MVI	B, 16;8
s_c01:	OUT	VDP
	DCR	B
	JNZ	s_c01
	;XRA	A
	;@OUT	DISP+1	; Stop displaying
	POP	B
	POP	H
	RET
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
	CALL	T_SetAddrWriteHL
	LDA	CURSYM
	OUT	VDP
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
	PUSH	H
	PUSH	D
	PUSH	B
	XCHG
	DCR	D
	DCR	E
	CALL	HideCursor
sc03:
	CALL	T_TextPos
	CALL	T_SetAddrReadHL
	IN	VDP
	STA	CURSYM
	SHLD	CURADDR
	CPI	'2' ; No idea - when setting cursor on this symbol editor hangs
	JZ	sc05
	PUSH	H
	MOV	L,A
	MVI	H,0
	DAD	H	; 2
	DAD	H	; 4
	DAD	H	; 8
	DAD	H	; 16
	LXI	D, T_T80_VRAM_PATT_ADDRESS
	DAD	D
	CALL	T_SetAddrReadHL
	MVI	B, 16
	LXI	H, SYMBUF
	PUSH	H
	CALL	T_ShortReadBytes
	LXI	H, T_T80_VRAM_PATT_ADDRESS + 255 * 16
	CALL	T_SetAddrWriteHL
	POP	H
	MVI	B, 16
sc04:
	MOV	A,M
	XRI	255
	OUT	VDP
	INX	H
	DCR	B
	JNZ	sc04
	POP	H
	MVI	A,1
	STA	SYMSAVED
sc05:
	CALL	T_SetAddrWriteHL
	MVI	a,255
	OUT	VDP
	POP	B
	POP	D
	POP	H
	MOV	A,H
	ADI	ScrYOffset-1
	RET

SYMBUF:	DS	16

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
