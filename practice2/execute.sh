#!/bin/bash

DIR=$(dirname "$0")
if [ -z "$1" ] ; then
    echo usage: $0 \<substring\>
    exit 1
fi

echo $DIR/out/main \"$1\" $DIR/input.txt
$DIR/out/main "$1" $DIR/input.txt

