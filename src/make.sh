bison -yd parser.y && flex lexer.l && gcc -o test frontend/game.c logic/chess.c -Ilogic -Ifrontend y.tab.c lex.yy.c -lfl -lSDL -lSDL_image -g -std=c99

./test < ../res/pgn/Anand.pgn
