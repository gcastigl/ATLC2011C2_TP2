%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "structs.h"

#define WHITE_WINS 1
#define DRAW_GAME 2
#define BLACK_WINS 3

#define CHCK 1
#define CHCKMATE 2

#define ERROR -1

#define YYENDERROR 1

#define MAX_ROUNDS 100

int yylex(void);
void yyerror(char * s);





struct play plays[MAX_ROUNDS];

int curr_round = 0;


int handle_play( int round, struct move white, struct move black, int result);
int handle_short_play( int round, struct move white,  int result);
struct move get_move( struct piece piece, struct coord target, int extra);
struct move get_castle_move ( int is_long);
struct piece get_piece( char piece, char col, int row);
struct coord get_coord( char col, int row);
void print_play ( struct play * play);

%}

%union { int num; char * string; char ch; struct move mv;  struct coord coord; struct piece pc;}
%token <num> UNKNOWN
%token <num> DRAW
%token <num> INTEGER
%token <string> STRING
%token <ch> PIECE
%token <ch> COL
%token <num> ROW
%token <ch> SHORTCASTLE
%token <ch> LONGCASTLE
%token <ch> CHECK
%token <ch> CHECKMATEMOTHERFUCKER
%token <ch> FINALRESULT
%token <ch> CAPTURE
%token <num> ROUND

%type <string> program
%type <string> opts1
%type <string> opts2
%type <string> opts3
%type <string> opts4
%type <string> opts5
%type <string> opts6
%type <string> event
%type <string> site
%type <string> date
%type <string> round
%type <string> white
%type <string> black
%type <string> result
%type <num> res;
%type <num> datecomp;
%type <mv> move;
%type  <coord> target;
%type <num> extra;
%type <pc> piece;

%expect 4
%error-verbose

%%

program:
	event opts1
	;
opts1:
	site opts2
	;
opts2:
	date opts3
	;
opts3:
	round opts4
	;
opts4:
	white opts5
	;
opts5:
	black opts6
	;
opts6:
	result game
	;

event:
	'[' 'E' 'v' 'e' 'n' 't' ' ' STRING ']'  { int len = strlen($8) - 1;
														opts.event_name = malloc(len);
														memcpy(opts.event_name, $8 + 1, len); free($8);
														opts.event_name[len-1] = 0;}
	;
site:
	'[' 'S' 'i' 't' 'e' ' ' STRING ']' { int len = strlen($7) - 1;
														opts.site_name = malloc(len);
														memcpy(opts.site_name, $7 + 1, len); free($7);opts.site_name[len-1] = 0;}
	;
white:
	'[' 'W' 'h' 'i' 't' 'e' ' ' STRING ']' { int len = strlen($8) - 1;
														opts.white_player = malloc(len);
														memcpy(opts.white_player, $8 + 1, len);free($8);opts.white_player[len-1] = 0; }
	;
black:
	'[' 'B' 'l' 'a' 'c' 'k' ' ' STRING ']' { int len = strlen($8) - 1; 
														opts.black_player = malloc(len);
														memcpy(opts.black_player, $8 + 1, len);free($8);opts.black_player[len-1] = 0; }
	;
date:
	'[' 'D' 'a' 't' 'e' ' ' '"' datecomp '/' datecomp '/' datecomp '"' ']' {
																					opts.day = $12; opts.month = $10; opts.year = $8;
																					if(!date_is_valid(opts)){
																						yyerror("Date is invalid!\n");
																						return YYENDERROR;
																					}
																				}
	;
datecomp:
	INTEGER		{$$ = $1;}
	| UNKNOWN	{$$ = -1;}
	;
round:
	'[' 'R' 'o' 'u' 'n' 'd' ' ' STRING ']'  { int val = atoi($8 + 1);
												if(atoi == 0) {
													yyerror("Invalid round format!\n");
													return YYENDERROR;
												}
												opts.round = val;
											}
	;
result:
	'[' 'R' 'e' 's' 'u' 'l' 't' ' ' '"' res '"' ']'  {opts.result = $10;
															if(opts.result == ERROR ) {
																yyerror("Result is invalid!\n");
																return YYENDERROR;
															}
														}
	;
res:
	DRAW '-' DRAW { $$ = DRAW_GAME;}
	| INTEGER '-' INTEGER { $$ = get_result( $1, $3 );}
	;

//TODO not really tested...

game:
	play game
	| FINALRESULT
	;
play:
	ROUND  ' ' move ' ' move ' '		{handle_play($1, $3, $5, 0);}
	| ROUND ' ' move ' ' FINALRESULT	{handle_short_play($1, $3,  $5);}
	| ROUND ' ' move ' ' move ' ' FINALRESULT	{handle_play($1, $3, $5, $7);}
	;
move:
	piece target extra					{ $$ = get_move( $1, $2, $3);}
	| piece CAPTURE target extra		{ $$ = get_move ( $1, $3, $4);}
	| SHORTCASTLE						{ $$ = get_castle_move (0);}
	| LONGCASTLE						{ $$ = get_castle_move (1);}
	;
extra:
	CHECK								{ $$ = CHCK;}
	| CHECKMATEMOTHERFUCKER				{ $$ = CHCKMATE;}
	| 									{ $$ = 0 ;}
	;
piece:
	PIECE								{ $$ = get_piece($1, 0, 0);} 
	| PIECE COL							{ $$ = get_piece($1, $2, 0);}
	| PIECE ROW							{ $$ = get_piece($1, 0, $2);}
	| PIECE COL ROW						{ $$ = get_piece($1,$2,$3);}
	|									{ $$ = get_piece('P',0,0);}
	| COL								{ $$ = get_piece('P',$1,0);}
	;
target:
	COL ROW								{ $$ = get_coord( $1, $2);}
	;

%%

void print_move ( struct move * move) {

	if(move->shcastle){
		printf("0-0 ");
		return;
	}
	if(move->lgcastle){
		printf("0-0-0");
		return;
	}
	printf("From: %c%d,%d To: %d,%d", move->pc.piece, move->pc.src.col, move->pc.src.row, move->dst.col, move->dst.row);
	

}

void print_play ( struct play * play ) {

	printf("--------------------------");
	printf("Round %d\n", play->round);
	printf("White: ");print_move(&(play->white));
	printf("Black: ");print_move(&(play->black));
	

}

int date_is_valid ( struct options opts ) {
	
	int days[12] = { 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
	int valid = 1;
	if ( opts.month != -1 && opts.day > days[opts.month]) 
			valid = 0;
	if ( opts.month > 12 )
		valid = 0;
	return valid;
	
}

int get_result ( int white, int  black ) {
	
	int ret = ERROR;
	if( white == 1 && black == 0)
		ret = WHITE_WINS;
	else if( white == 0 && black == 1)
		ret = BLACK_WINS;
	return ret;
	
}

int handle_play( int round, struct move white, struct move black, int result){

	if(round != curr_round + 1){
		char msg [ 50 ];
		sprintf(msg, "Round error! Was %d, supposed to be %d\n", round, curr_round + 1);
		yyerror(msg);
		return YYENDERROR;
	}
	struct play * pl = &plays[curr_round];
	pl-> white = white;
	pl-> black = black;
	pl-> end = result;
	curr_round++;
	print_play(pl);


}

int handle_short_play( int round, struct move white, int result){

	if(round != curr_round + 1){
		char msg [ 50 ];
		sprintf(msg, "Round error! Was %d, supposed to be %d\n", round, curr_round + 1);
		yyerror(msg);
		return YYENDERROR;
	}
	struct play * pl = &plays[curr_round];
	pl-> white = white;
	pl-> end = result;
	curr_round++;


}


struct move get_move( struct piece piece, struct coord target, int extra){

	struct move ret;
	ret.lgcastle = 0; ret.shcastle = 0;
	if(extra == CHCK)
		ret.check = 1;
	else if (extra == CHCKMATE)
		ret.checkmate = 1;
	ret.pc = piece;
	ret.dst = target;
	return ret;


}




struct move get_castle_move ( int is_long){

	struct move ret;
	if(is_long)
		ret.lgcastle = 1;
	else
		ret.shcastle = 1;
	return ret;


}


struct piece get_piece( char piece, char col, int row){

	struct piece ret;
	ret.piece = piece;
	ret.src = get_coord(col, row);
	return ret;

}


struct coord get_coord( char col, int row){
	struct coord ret;
	ret.col = col - 'a';
	ret.row = row - 1;
	return ret;
}



void yyerror(char * s){
	
	fprintf(stderr, "%s\n", s);
	return;
}

//Debugging purposes

void print_options( struct options o ) {
	printf("Event: %s\n", o.event_name);
	printf("Site: %s\n", o.site_name);
	printf("White Player: %s\n", o.white_player);
	printf("Black Player: %s\n", o.black_player);
	printf("Round: %d\n", o.round);
	printf("Year: %d, Month: %d, Day: %d\n", o.year, o.month, o.day);
	printf("Result: %d\n", o.result);
	
	
}

int main( void ) {
	yyparse();
	print_options(opts);
	return 0;
}
