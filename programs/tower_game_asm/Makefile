SRCS=$(wildcard *.asm)
TAPS=$(SRCS:.asm=.tap)

default: $(TAPS)

run: clean main.tap
	/Users/kbuzsaki/dev/cse190/fuse/Fuse.app/Contents/MacOS/Fuse main.tap

include ../makefile.defs
