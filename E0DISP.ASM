;----- Display one editor string ----------

;include E0DISP.MAC
;include RK86.MAC
IFNDEF	CURSM
extrn CURSM
EXTRN	DISP_ADR, DMA_ADR, VRAM_ADR
ENDIF

SETSCR::
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

	
SetCursor::
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


LPOS:	DB	0
;RK_END
@RK_END::
	DW	0
IFNDEF	noend
	END
ENDIF
