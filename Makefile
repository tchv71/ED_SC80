EMUPATH=D:\Emu80qt_40444
M80PATH=D:/M80
ASMDEP=EDSC80.ASM E0MAIN.ASM E0FILEIO.ASM E0CMDT.ASM E0GETC.ASM E0DISP.ASM E0DISP.MAC RK86.MAC E0BREAK.MAC RkConfig.mac
PORT=COM2

.SUFFIXES: .ASM .REL .BIN

.ASM.REL:
	$(M80PATH)/M80 '$@=$< /I/L'

EDSC803.REL: $(ASMDEP)
	$(M80PATH)/M80 '$@=$< /I/L'

EDSC806.REL: $(ASMDEP)
	$(M80PATH)/M80 '$@=$< /I/L'

EDSC80P.REL: $(ASMDEP)
	$(M80PATH)/M80 '$@=$< /I/L'

EDSC80PC.REL: $(ASMDEP)
	$(M80PATH)/M80 '$@=$< /I/L'

clean:
	del *.REL
	del *.PRN
	del *.BIN

all: bin/ESC80_palmira.rkl bin/ESC80_32k.rk bin/ESC80_60k.rk

send: bin\ESC80_CPM.rkl
	MODE $(PORT): baud=115200 parity=N data=8 stop=1
	cmd /C copy /B  $< $(PORT)

palmira:
	copy /y RkConfigPalmira.mac RkConfig.mac
# touch equivalent
	copy /b RkConfig.mac +,,

palmiraCPM:
	copy /y RkConfigPalmiraCPM.mac RkConfig.mac
# touch equivalent
	copy /b RkConfig.mac +,,

Rk60k:
	copy /y RkConfig60k.mac RkConfig.mac
	copy /b RkConfig.mac +,,

Rk32k:
	copy /y RkConfig32k.mac RkConfig.mac
	copy /b RkConfig.mac +,,

bin/ESC80_CPM.rkl: palmiraCPM EDSC80PC.BIN
	../makerk/Release/makerk.exe 100 EDSC80PC.BIN $@

bin/ESC80_palmira.rkl: palmira EDSC80P.BIN
	../makerk/Release/makerk.exe 100 EDSC80P.BIN $@

bin/ESC80_60k.rk: Rk60k EDSC806.BIN
	../makerk/Release/makerk.exe 100 EDSC806.BIN $@

bin/ESC80_32k.rk: Rk32k EDSC803.BIN
	../makerk/Release/makerk.exe 100 EDSC803.BIN $@

.REL.BIN:
	$(M80PATH)/L80 /P:100,$<,$@/N/Y/E

EDSC80P.BIN: EDSC80P.REL

run: bin/ESC80_32k.rk
	$(EMUPATH)/Emu80Qt bin/ESC80_palmira.rk
