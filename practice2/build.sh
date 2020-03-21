#!/bin/bash

DIR=$(dirname "$0")
echo g++ -std=c++17 -o $DIR/out $DIR/main.cpp
g++ -std=c++17 -o $DIR/out $DIR/main.cpp


