#!/bin/bash

DIR=$(dirname "$0")
if test "$1" != 'subtract' && test "$1" != 'multiply' ; then
    echo usage: $0 \[subtract\|multiply\]
    exit 1
fi

$DIR/out/$1 < $DIR/input.txt

