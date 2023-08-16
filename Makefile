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

all: bin/ESC80_palmira.rkl bin/ESC80_32k.rk bin/ESC80_60k.rk bin/ESC80_CPM.rkl
send: bin\ESC80_CPM.rkl
	MODE $(PORT): baud=115200 parity=N data=8 stop=1
	cmd /C copy /B  $< $(PORT)

_palmira: RkConfigPalmira.mac
	copy /y RkConfigPalmira.mac RkConfig.mac
	copy /y RkConfigPalmira.mac _palmira
# touch equivalent
	copy /b RkConfig.mac +,,
	copy /b RkConfig60k.mac +,,
	copy /b RkConfigPalmiraCPM.mac +,,
	copy /b RkConfig32k.mac +,,

_palmiraCPM: RkConfigPalmiraCPM.mac
	copy /y RkConfigPalmiraCPM.mac RkConfig.mac
	copy /y RkConfigPalmiraCPM.mac _palmiraCPM
# touch equivalent
	copy /b RkConfig.mac +,,
	copy /b RkConfig60k.mac +,,
	copy /b RkConfigPalmira.mac +,,
	copy /b RkConfig32k.mac +,,

_Rk60k: RkConfig60k.mac
	copy /y RkConfig60k.mac RkConfig.mac
	copy /y RkConfig60k.mac _Rk60k
# touch equivalent
	copy /b RkConfig.mac +,,
	copy /b RkConfigPalmiraCPM.mac +,,
	copy /b RkConfigPalmira.mac +,,
	copy /b RkConfig32k.mac +,,

_Rk32k: RkConfig32k.mac
	copy /y RkConfig32k.mac RkConfig.mac
	copy /y RkConfig32k.mac _Rk32k
# touch equivalent
	copy /b RkConfig.mac +,,
	copy /b RkConfigPalmiraCPM.mac +,,
	copy /b RkConfigPalmira.mac +,,
	copy /b RkConfig60k.mac +,,

bin/ESC80_CPM.rkl: _palmiraCPM EDSC80PC.BIN
	../makerk/Release/makerk.exe 100 EDSC80PC.BIN $@

bin/ESC80_palmira.rkl: _palmira EDSC80P.BIN
	../makerk/Release/makerk.exe 100 EDSC80P.BIN $@

bin/ESC80_60k.rk: _Rk60k EDSC806.BIN
	../makerk/Release/makerk.exe 100 EDSC806.BIN $@

bin/ESC80_32k.rk: _Rk32k EDSC803.BIN
	../makerk/Release/makerk.exe 100 EDSC803.BIN $@

.REL.BIN:
	$(M80PATH)/L80 /P:100,$<,$@/N/Y/E

run: bin/ESC80_32k.rk
	$(EMUPATH)/Emu80Qt bin/ESC80_palmira.rk
