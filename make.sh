#! /bin/sh

# Cleanup
rm -rf bin
mkdir bin
cd ./bin

# variables
FLAGS='-Wall -pedantic -std=c99'
INCLUDE='../src/'

# Compile lex files
touch chess.c

# Compile and link with other C sources
gcc $FLAGS -I$INCLUDE *.c ../src/logic/*.c -lfl -o -g

