;********************************************************
;*  SC80 text screen editor       File I/O module  CP/M *
;*                        (c) TCHV,1989-93              *
;********************************************************

EXTRN	PRINT,INFSTR,nivgr,werhgr,START,CURX,INFPR,BLBEG,BLEND
EXTRN	JMPBL,OUT1,CLRSTR,FILNAM,NAMMES,INPSTR,GETCHR,MAXRAM,MARK,DISADR,CDEHL
FCB	EQU	5CH

RDFIL::	LXI	H,0
	CALL	0F824H
	XCHG
	SHLD	werhgr
	JMP	START


RDBL::	LHLD	werhgr
	INX	H
	LXI	D,-2000H
	DAD	D
	CALL	0F824H ; Read block from tape
	XCHG
	SHLD	BLEND
	DCX	H
	SHLD    werhgr
	POP	H
	SHLD	CURX
	CALL	JMPBL
	JMP	OUT1

WRFIL::
	CALL	MARK
	PUSH	H
	LHLD	nivgr
	XCHG
	LHLD	werhgr
	XCHG
	CALL	WRSEG
	POP	H
	JMP	DISADR

WRBL::	CALL	MARK
	PUSH	H
	LHLD	BLBEG
	XCHG
	LHLD	BLEND
	DCX	H
	XCHG
	CALL	WRSEG
	POP	H
	JMP	DISADR


WRSEG:
	CALL	0F82AH ; Checksum calc
	JMP	0F827H ; Write block to tape
	END
