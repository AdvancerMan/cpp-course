#!/bin/bash

DIR=$(dirname "$0")

FILES=(subtract multiply)

mkdir $DIR/out

for FILE in ${FILES[@]}
do
	nasm -f elf64 -g -F dwarf -o $DIR/out/$FILE.o $DIR/$FILE.asm
	ld $DIR/out/$FILE.o -o $DIR/out/$FILE
done
