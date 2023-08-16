;********************************************************
;*  SC80 text screen editor       COMMAND table module  *
;*                        (c) TCHV,1989-93              *
;********************************************************


IFNDEF INFADR
INCLUDE E0DISP.MAC
PUBLIC	FNDCMD
EXTRN INFADR
ENDIF

@Left		equ	8h
@Right		equ	18h
@Up		equ	19h
@Down		equ	1Ah
@Str		equ	31
Shift		equ	80h
Cntrl		equ	40h


CMD	MACRO	Adr1,Key1,Adr2,Key2
;extrn	Adr1
	DW	Adr1,Key1
	ifnb	<Adr2>
;extrn	Adr2
	DW	Adr2,Key2
	endif
	ENDM

	;dseg
; *** Editor command table ***
; DW CMD_ADDR
; DB First Command sym, should be ANDed with 40h or ORed with 40h if Ctrl assumed pressed
; DB Second command sym or 0
CMDTBL::
	CMD	LFTM,	@Left,		RHTM,	@Right
	CMD	UPM,	@Up,		DWNM,	@Down
	CMD	SCRLUP,	Shift+@Up,	SCRLDN,	Shift+@Down
	CMD	REPMOD,	2
	DW	0

	CMD	INSCTRL,0
	CMD	LDEL,	3Fh,		RDEL,	3
	CMD	TAB,	9,		BSC,	12
	CMD	CR,	13,		REST,	27
	CMD	DELLT,	Cntrl+1,	DELRT,	Cntrl+3
	CMD	LEND,	Cntrl+@Left,	REND,	Cntrl+@Right
	CMD	INSSPC,	Cntrl+2,	BRKSTR,	Cntrl+13
	DW	0

	CMD	JoinStr,'J'
	DW	0

	CMD	CALC,	@Str+'C'*256;,	ASSM	@Str+'A'*256
	CMD	SEARCH,	@Str+'S'*256,	REPLACE,@Str+'R'*256
	CMD	NEW,	@Str+'N'*256;,	VERIFY,	@Str+'V'*256
	CMD	BEGBUF,	@Str+@Up*256,	ENDBUF,	@Str+@Down*256
	CMD	EXIT,	@Str+'E'*256
	CMD	RDFIL,	@Str+('R'-Cntrl)*256
	CMD	WRFIL,	@Str+('W'-Cntrl)*256
	CMD	PAGEUP,	Cntrl+@Up,	PAGEDN,	Cntrl+@Down

	CMD	DELLIN,	'D', 	CONT_SRREP, 	'L' ; Continue SEARCH/REPLACE
	CMD	SWPWIN,	'W', WINUP,'U'
	CMD	WINDN,	'K'

	;*****	Block	commands *****
	CMD	DISBEG,	'Q'+@Left*256,	DISEND,	'Q'+@Right*256
	CMD	MRBEG,	'Q'+@Up*256,	MREND,	'Q'+@Down*256
	CMD	RDBL,	'Q'+('R'-Cntrl)*256
	DW	0
	CMD	DELBL,	'Q'+('D'-Cntrl)*256
	CMD	WRBL,	'Q'+('W'-Cntrl)*256
	CMD	COPYBL,	'Q'+('C'-Cntrl)*256
	CMD	JMPBL,	'Q'+('J'-Cntrl)*256
	DW	0

	cseg

; **************  Find disk command ****************
; Executes command or returns if command not found
; c - first char of command sequence ;  HL - pointer to command table
FNDCMD:	INX	H
	inr	m	; Test High byte of command adress
	dcr	m
	INX	H
	rz	; Return if command not found
	mov	a,c
	CMP	M
	JZ	FirstSym	; First symbol is ok
	INX	H
ContCmdSearch:
	INX	H
	JNZ	FNDCMD
	INX	D
	INX	D
	RET

FirstSym:
	INX	H
	INR	M
	DCR	M	; is second symbol required
	JZ	CmdFound

	push	h
	MOV	C,A
	;lxi	h,INFSTR+1
	CALL	GETINFADR
	INX	H
	SetScrAddr
	MVI	A,'^'
	WriteNextSym

	mov	a,c
	ANI	3FH
	ADI	40H
	WriteNextSym
	POP	H

	MOV	A,B	; Read next symbol if needed
	ORA	A
	CZ	GETCHR
	ani	11011111b	; toupper(Acc)
	MOV	B,A
	CMP	M
	JNZ	ContCmdSearch

CmdFound:
	pop	d	; Drop	return address
	dcx	h
	dcx	h
	mov	d,m
	dcx	h
	mov	e,m
	XCHG
	PCHL

	END

;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

