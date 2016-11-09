main: pipe2600.bas.bin

pipe2600.bas.bin: pipe2600.bas
	PATH=$(PATH):${bB} ${bB}/2600basic.sh pipe2600.bas

clean:
	rm -f 2600basic_variable_redefs.h bB.asm includes.bB pipe2600.bas.asm pipe2600.bas.bin pipe2600.bas.list.txt pipe2600.bas.symbol.txt

debug:
	stella pipe2600.bas.bin
