#!/bin/zsh

ARQ=`basename $1|sed "s/\.pas//"`

java Parser $ARQ.pas >$ARQ.s
# 32 bits
# as -o $ARQ.o $ARQ.s
#ld -o $ARQ   $ARQ.o

# 64 bits 
as --32 -o $ARQ.o $ARQ.s
ld -m elf_i386 -s -o $ARQ   $ARQ.o
