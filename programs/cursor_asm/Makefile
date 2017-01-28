SRCS=$(wildcard *.asm)
TAPS=$(SRCS:.asm=.tap)

default: $(TAPS)

run: default
	open -a fuse $(TAPS)

include ../makefile.defs
