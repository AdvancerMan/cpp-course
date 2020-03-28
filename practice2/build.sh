#!/bin/bash

DIR=$(dirname "$0")
mkdir $DIR/out

echo g++ -std=c++17 -o $DIR/out/main $DIR/main.cpp
g++ -std=c++17 -o $DIR/out/main $DIR/main.cpp


