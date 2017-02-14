SRCS=$(wildcard *.asm)
TAPS=$(SRCS:.asm=.tap)

default: $(TAPS)

run: default
	/Users/kbuzsaki/dev/cse190/fuse/Fuse.app/Contents/MacOS/Fuse $(TAPS)

include ../makefile.defs
