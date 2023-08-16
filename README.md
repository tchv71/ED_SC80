# ED_SC80
CP/M hardware dependent SC80 text editor for RK86 60K, RK86 32K, Palmira

This editor can read/write CP/M text files but uses RK86 direct text screen access - therefore more fast than using standard console i/o

Text blocks and 2 text windows are supported

Makefile is for compilation on PC (using M80 and L80 wrappers from here: https://github.com/Konamiman/M80dotNet)

There are additional 3 configurations for original computers without CP/M:

bin/ESC80_32k.rk - Radio 86 RK with 32k memory

bin/ESC80_60k.rk - Radio 86 RK with 60k memory

bin/ESC80_palmira.rkl - Palmira


You can use 'make all' to build all configurations or 'make bin/ESC80_60k.rk' for particular configuration 
