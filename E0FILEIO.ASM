;********************************************************
;*  SC80 text screen editor       File I/O module  Tape *
;*                        (c) TCHV,1989-93              *
;********************************************************

IFNDEF	nivgr
EXTRN	nivgr,werhgr,START,CURX,BLBEG,BLEND
EXTRN	JMPBL,OUT1, MARK,DISADR
ENDIF

IFNDEF	CPM

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
ELSE
; CPM
FCB	EQU	5CH
BUFF	EQU	80H
RDFIL::	CALL	DISHDL
RDFIL01:
	JNZ	RDF0
	CALL	INFPR
	DW	0; INFSTR
	DB	'NOT FOUND',80H
	CALL	INPNAM
	JMP	RDFIL01

RDF0:	LHLD	nivgr
	CALL	RDBOD
	LHLD	nivgr
	MOV	D,H
	MOV	E,L
	CALL	CONVRT
	XCHG
	SHLD	werhgr
	LXI	H,0
	SHLD	BUFF
	JMP	START


RDBL::	LHLD	CURX
	PUSH	H
	CALL	DISHDL
RDB00:	JNZ	RDB0
	CALL	INFPR
	DW	0
	DB	'NOT FOUND',80H
	CALL	INPNAM
	JMP	RDB00

RDB0:	LHLD	werhgr
	INX	H
	CALL	RDBOD
	LHLD	werhgr
	INX	H
	SHLD	BLBEG
	MOV	D,H
	MOV	E,L
	CALL	CONVR0
	XCHG
	SHLD	BLEND
	DCX	H
	SHLD    werhgr
	POP	H
	SHLD	CURX
	CALL	JMPBL
	JMP	OUT1


CONVR0:	MOV	A,M
	CPI	1AH
	RZ
	INX	H
	CPI	0AH
	JZ	CONVR0
	STAX	D
	INX	D
	JMP	CONVR0
CONVRT:	CALL	CONVR0
CONV0:	DCX	D
	LDAX	D
	INX	D
	CPI	0DH
	JZ	CONV1
	MVI	A,0DH
	STAX	D
	INX	D
CONV1:	MVI	A,0FFH
	STAX	D
	RET


DISHDL:	CALL	CLRSTR
	CALL	INFPR
	DW	1
	DC	'READ'
DISH0:	CALL	INFPR
	DW	10
	DC	'FILE:'
	LXI	H,FILNAM
	LXI	B,NAMMES
	CALL	INPSTR
RD20:	CALL	INFPR
	DW	33
	DC	'FILE:'
	LXI	H,FILNAM
	LXI	D,FCB
	CALL	GTFNAM
	LXI	D,BUFF
	MVI	C,1AH
	CALL	5
	LXI	D,FCB
	MVI	C,11H
	CALL	5	; SEARCH FIRST
	INR	A
	RZ
	LXI	H,BUFF
	LXI	B,20H
DSP0:	DCR	A
	JZ	DSP1
	DAD	B
	JMP	DSP0
DSP1:	XCHG
	PUSH	D
	;LXI	H,INFSTR+38
	CALL	GETINFADR
	LXI	B,38
	DAD	B
	POP	D
	INX	D
	MVI	B,8
	CALL	DSH00
	MVI	A,'.'
	MOV	M,A
	INX	H
	MVI	B,3
DSH00:	LDAX	D
	MOV	M,A
	INX	H
	INX	D
	DCR	B
	JNZ	DSH00
	XRA	A
	INR	A
	RET

GTFNAM:	MOV	A,M
	CPI	20H
	JNZ	GTN99
	INX	H
	JMP	GTFNAM
GTN99:	PUSH	D
	XRA	A
	MVI	C,36 ;25H
	STAX	D
	INX	D
	DCR	C
	JNZ	$-3
	POP	D
	INX	H
	MOV	A,M
	DCX	H
	CPI	':'
	JNZ	GTNAM
	MOV	A,M
	INX	H
	INX	H
	ANI	0FFH-20H
	SUI	40H
	STAX	D
GTNAM:	INX	D
	MVI	C,8
	CALL	GTN0
	MOV	A,M
	CPI	'.'
	JNZ	$+4
	INX	H
	MVI	C,3
	CALL	GTN0
	RET

GTN0:	MOV	A,M
	CPI	61H
	JC	$+5
	SUI	20H
	INX	H
	CPI	'.'
	MVI	B,20H
	JZ	GTN1
	CPI	20H
	JC	GTN1
	CPI	'*'
	MVI	B,'?'
	JZ	GTN1
	STAX	D
	INX	D
	DCR	C
	JNZ	GTN0

GTN1:	MOV	A,B
	INR	C
	DCR	C
	RZ
	STAX	D
	INX	D
	JMP	$-4


RDBOD:	PUSH	H	; READ FILE FROM DISK
	LXI	D,FCB
	MVI	C,0FH	; OPEN FILE
	CALL	5
	INR	A
	POP	H
	JNZ	DS00

ERR1:	CALL	CLRSTR
	CALL	INFPR
	DW	39
	DB	'UNABLE OPEN FILE',80H
	CALL	GETCHR
	LXI	H,0
	SHLD	BUFF
	JMP	START_COLD


DS00:
RDLOOP:	PUSH	H
	XCHG
	MVI	C,1AH
	CALL	5
	LXI	D,FCB
	MVI	C,14H
	CALL	5
	POP	H
	LXI	D,128
	DAD	D
	ORA	A
	JZ	RDLOOP
; pokamest perepolnenie ne opredelqem
	LXI	D,FCB
	MVI	C,10H
	CALL	5
	;CALL	MAXRAM
	;MVI	M,1AH
	RET


WRFIL::
	CALL	MARK
	PUSH	H
	CALL	DISHW
	LHLD	nivgr
	XCHG
	LHLD	werhgr
	XCHG
	CALL	WRSEG
	POP	H
	JMP	DISADR

WRBL::	CALL	MARK
	PUSH	H
	CALL	DISHW
	LHLD	BLBEG
	XCHG
	LHLD	BLEND
	DCX	H
	XCHG
	CALL	WRSEG
	POP	H
	JMP	DISADR


WRSEG:	PUSH	H
	PUSH	D
	LXI	D,FCB
	MVI	C,13H	; ERASE FILE
	CALL	5
	LXI	D,FCB
	MVI	C,16H	; OPEN FILE
	CALL	5
	LXI	D,BUFF
	MVI	C,1AH
	CALL	5
	POP	D
	POP	H
	PUSH	H
	LXI	H,BUFF
	MVI	B,80H
	INX	D
WRB00:	XTHL
	CALL	CDEHL
	JZ	WRB10
	MOV	A,M
	INX	H
	XTHL
	CPI	0FFH
	JZ	WRB11
	CPI	0DH
	JNZ	$+8
	CALL	TOBUF
	MVI	A,0AH
	CALL	TOBUF
	JMP	WRB00
TOBUF:	MOV	M,A
	INX	H
	DCR	B
	RNZ
PUSHS:	PUSH	D
	LXI	D,FCB
	MVI	C,15H
	CALL	5
	POP	D
	MVI	B,80H
	LXI	H,BUFF
	RET

WRB10:	XTHL
WRB11:	MVI	A,1AH
	CALL	TOBUF
	POP	H
	MOV	A,B
	CPI	80H
	CNZ	PUSHS
	LXI	D,FCB
	MVI	C,10H
	CALL	5
	RET


DISHW:	CALL	CLRSTR
	CALL	INFPR
	DW	1
	DC	'WRITE'
	CALL	INFPR
	DW	10
	DC	'FILE:'
INPNAM:	LXI	H,FILNAM
	LXI	B,NAMMES
	CALL	INPSTR
	JMP	RD20
ENDIF

IFNDEF	noend
	END
ENDIF
