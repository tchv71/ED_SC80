;********************************************************
;*  SC80 text screen editor       File I/O module  Tape *
;*                        (c) TCHV,1989-93              *
;********************************************************

IFNDEF	nivgr
EXTRN	nivgr,werhgr,START,CURX,BLBEG,BLEND
EXTRN	JMPBL,OUT1, MARK,DISADR
ENDIF

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
IFNDEF	noend
	END
ENDIF
