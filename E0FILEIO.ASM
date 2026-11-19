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
	ORA	A
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
	ORA	A
	JZ	CONV1
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
IFNDEF SHELL
	LXI	D,FCB
	CALL	GTFNAM
	LXI	D,BUFF
	MVI	C,1AH	; SET DMA
	CALL	5
	LXI	D,FCB
	MVI	C,11H	; SEARCH FIRST
	CALL	5
	INR	A
	RZ
	LXI	H,BUFF
	LXI	B,20H
DSP0:	DCR	A
	JZ	DSP1
	DAD	B
	JMP	DSP0
DSP1:	XCHG
	INX	D
ELSE
	lxi	h, BUFF
	PUSH	H
	lxi	d, 1
	mvi	a, FS_FIND
	call	fs
	ora	a
	POP	D
	RNZ
ENDIF
	;LXI	H,INFSTR+38
	CALL	GETINFADR
	LXI	B,38
	DAD	B
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

IFNDEF SHELL
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
ENDIF

ERR1:	CALL	CLRSTR
	CALL	INFPR
	DW	39
	DB	'UNABLE OPEN FILE',80H
	CALL	GETCHR
	LXI	H,0
	SHLD	BUFF
	JMP	START_COLD

FileTooBig:
	CALL	CLRSTR
	CALL	INFPR
	DW	39
	DB	'FILE TOO BIG',80H
	CALL	GETCHR
	LXI	H,0
	SHLD	BUFF
	JMP	START_COLD

ErrFileRead:
	CALL	CLRSTR
	CALL	INFPR
	DW	39
	DB	'FILE READ ERROR',80H
	CALL	GETCHR
	LXI	H,0
	SHLD	BUFF
	JMP	START_COLD

RDBOD:
IFNDEF SHELL
	PUSH	H	; READ FILE FROM DISK
	LXI	D,FCB
	MVI	C,0FH	; OPEN FILE
	CALL	5
	INR	A
	POP	H
	JZ	ERR1
RDLOOP:	PUSH	H
	XCHG
	MVI	C,1AH	; SET DMA
	CALL	5
	LXI	D,FCB
	MVI	C,14H	; Read Sequential
	CALL	5
	POP	H
	LXI	D,128
	DAD	D
	ORA	A
	JZ	RDLOOP
; pokamest perepolnenie ne opredelqem
	LXI	D,FCB
	MVI	C,10H	;  Close File
	CALL	5
	;CALL	MAXRAM
	;MVI	M,1AH
	RET
ELSE
O_OPEN	equ	0
O_DELETE equ	100
FS_EXEC	equ	0
FS_FIND	equ	1
FS_OPEN	equ	2
FS_SEEK	equ	3
FS_READ	equ	4
FS_WRITE equ	5

	PUSH	H
	lhld	fs_cmdLine
	MVI	D,O_OPEN
	mvi	a, FS_OPEN
	call	fs
	ora	a
	POP	H
	jnz	ERR1

	push	h
	lxi	h,0
	mvi	b,100
	mvi	a, FS_SEEK
	call	fs
	mov	a,e
	ora	d
	xchg
	pop	h
	jnz	FileTooBig
	xchg
	push	h
	push	d
	mvi	a, FS_READ
	call	fs
	pop	d
	pop	h
	ora	a
	jnz	ErrFileRead
	dad	d
	mvi	m,1ah
	ret

LoadFont:
IFDEF	SHELL
	lxi	h, fntName
	MVI	D,O_OPEN
	mvi	a, FS_OPEN
	call	fs
	ora	a
	rnz

	lxi	b,T_T80_VRAM_PATT_ADDRESS;2000h
	call	T_SetAddrWrite
	mvi	c, 4096 / 512;
lf00:
	lhld	RamTop
	xchg
	lxi	h, 512
	push	h
	push	d
	push	b
	mvi	a,FS_READ
	call	fs
	pop	b
	pop	h
	pop	d
	ora	a
	rnz
	call	T_WriteBytes
	dcr	c
	jnz	lf00
ENDIF
	ret


; BC - address to write
T_SetAddrWrite:
	MOV	A,B
	ORI	40h
	MOV	B,A
; BC - address to read
T_SetAddrRead:
	DI
	MOV	A,C
	OUT	VDP+1
	MOV	A,B
	OUT	VDP+1
	EI
	RET

fntName:	DB	"BOOT/F8X16R.BIN",0

ENDIF

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

SAVE:
	lhld	fs_cmdLine
	lxi	d, FILNAM
sav00:
	mov	a, m
	inx	h
	stax	d
	inx	d
	ora	a
	jnz	sav00
	LHLD	nivgr
	XCHG
	LHLD	werhgr
	XCHG
WRSEG:
IFNDEF	SHELL
	PUSH	H
	PUSH	D
	LXI	D,FCB
	MVI	C,13H	; ERASE FILE
	CALL	5
	LXI	D,FCB
	MVI	C,16H	; OPEN FILE
	CALL	5
	LXI	D,BUFF
	MVI	C,1AH	; SET DMA
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
	MVI	C,15H	; Write Sequential
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
	MVI	C,10H	; Close File
	CALL	5
ELSE
O_DELETE	equ	100
O_CREATE	equ	1


	push	d
	push	h
	lxi	h, FILNAM
	push	h
	mvi	d, O_DELETE
	mvi	a, FS_OPEN
	call	fs
	pop	h
	mvi	d, O_CREATE
	mvi	a, FS_OPEN
	call	fs
	pop	h
	pop	d
	call	WrInitBuf
	inx	d
WRB00:
	call	CDEHL
	jz	WRB10
	mov	a,m
	inx	h
	cpi	0ffh
	jz	WRB11
	cpi	0dh
	jnz	$+8
	call	TOBUF
	mvi	a,0ah
	call	TOBUF
	jmp	WRB00
TOBUF:	stax	b
	inx	b
	lda	WrCount
	dcr	a
	sta	WrCount
	rnz
	lda	WrCount+1
	ora	a
	jz	PUSHS
	dcr	a
	sta	WrCount+1
	RET
PUSHS:	push	h
	push	d
	lhld	WrCount
	lxi	d,512
	xchg
	call	?subhlde
	xchg
	lhld	RamTop
	xchg
	mvi	a, 5
	call	fs
	pop	d
	pop	h
WrInitBuf:
	lda	RamTop
	mov	c,a
	lda	RamTop+1
	mov	b,a

	xra	a
	sta	WrCount
	inr	a
	sta	WrCount+1 ; 512
	ret
WrCount:
	DS	2
WRB10:
WRB11:	mvi	a,1ah
	call	TOBUF
	lda	WrCount
	ora	a
	jnz	PUSHS
	lda	WrCount+1
	ora	a
	jz	PUSHS

	;lxi	d,fcb
	;mvi	c,10h	; close file
	;call	5

ENDIF
	ret


DISHW:	CALL	CLRSTR
	CALL	INFPR
	DW	1
	DC	'WRITE'
	CALL	INFPR
	DW	10
	DC	'FILE:'
INPNAM:
	call	COPY_FILENAME
	;LXI	H,FILNAM
	;LXI	B,NAMMES
	;CALL	Get_key;INPSTR
	JMP	RD20
ENDIF

IFNDEF	noend
	END
ENDIF
