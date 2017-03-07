SRCS=$(wildcard *.asm)
TAPS=$(SRCS:.asm=.tap)

default: main.tap

new: clean default

run: new
	/Users/kbuzsaki/dev/cse190/fuse/Fuse.app/Contents/MacOS/Fuse main.tap

include ../makefile.defs
