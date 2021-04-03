;----- Display one editor string ----------

include E0DISP.MAC
include RK86.MAC
extrn CURSM

SETSCR::
	;RET
	LXI	H,DISP+1
	MVI	M,0
	DCX	H
	MVI	M,ScrWidth-1
	MVI	M,(ScrHeight+5-1)
 	MVI	M,99H
	mov	m,a
	INX	H
	MVI	M,27H
	MOV	A,M
	MOV	A,M
	ANI	20H
	JZ	$-3
	LXI	H,DMA+8
	MVI	M,80H
	MVI	L,Low(DMA+4)
	MVI	M,Low(ScrStart)
	MVI	M,High(ScrStart)
	INX	H
	MVI	M,Low(ScrSize-1)
	MVI	M,High(ScrSize-1) or 40h
	MVI	L,Low(DMA+8)
	MVI	M,0A4H
	RET
	
SetCursor::
	MVI	A,80H
	STA	DISP+1
	MOV     A,L
LPS:
	PUSH	H
	LXI	H,LPOS
	ADD	M
	INX	H
	ADD	M
	POP	H
	DCR	A
	ADI	ScrXOffset
	STA	DISP
	MOV	A,H
	ADI	2
	STA	DISP
	RET

LPOS:	DB	0
;RK_END
@RK_END::
	DW	0
	end
