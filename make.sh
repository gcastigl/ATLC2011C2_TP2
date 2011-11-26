#! /bin/sh

# Cleanup
rm -rf bin
mkdir bin
cd ./bin

# variables
FLAGS='-Wall -pedantic -std=c99'
INCLUDE='-I../src/ -I../src/logic/ -I../src/frontend -I.'
LIBS='-lSDL -lfl -lSDL_image'

# Compile lex files
bison -yd ../src/parser.y
flex ../src/lexer.l

# Compile and link with other C sources
gcc $FLAGS $INCLUDE *.c ../src/logic/*.c ../src/frontend/*.c $LIBS -o ../chess -g

