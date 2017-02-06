# This makefile facilitates downloading and compiling the different tools
# used for the project without having to commit them to the repository directly.
#
# I did this because I didn't want to risk infringing on the licenses of the
# tools by reproducing their source code.
#

.PHONY: default clean new

default: bin/z80asm bin/bas2tap bin/bin2tap

clean:
	rm -rf zip bin

new: clean default


# targets for compiling the binaries
bin:
	mkdir -p bin

bin/z80asm: | bin/ zip/z80asm-1.8/
	make -C zip/z80asm-1.8 >/dev/null 2>/dev/null
	cp zip/z80asm-1.8/z80asm bin/

bin/bas2tap: | bin/ zip/bas2tap/
	gcc zip/bas2tap/bas2tap.c -o bin/bas2tap -lm

bin/bin2tap: | bin/ zip/bin2tap/
	gcc zip/bin2tap/bin2tap.c -o bin/bin2tap -lm


# targets for downloading and extracting the source
zip:
	mkdir -p zip

zip/z80asm.tar.gz: zip/
	wget -q "http://download.savannah.gnu.org/releases/z80asm/z80asm-1.8.tar.gz" -O zip/z80asm.tar.gz

zip/z80asm-1.8: zip/z80asm.tar.gz
	cd zip && tar xfz "z80asm.tar.gz"

zip/bin2tap.zip: zip/
	wget -q "http://zeroteam.sk/files/bin2tap13.zip" -O zip/bin2tap.zip

zip/bin2tap: zip/bin2tap.zip
	cd zip && unzip -q bin2tap.zip

zip/bas2tap.zip: zip/
	wget -q "http://www.worldofspectrum.org/pub/sinclair/tools/generic/bas2tap26-generic.zip" -O zip/bas2tap.zip

zip/bas2tap: zip/bas2tap.zip
	cd zip && unzip -q bas2tap.zip -d bas2tap/

