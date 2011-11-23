%{
#include <stdlib.h>
#include <stdio.h>

#define WHITE_WINS 1
#define DRAW 2
#define BLACK_WINS 3

#define ERROR -1

#define YYERROR 1

int yylex(void);
%}

%union { int num; char * string; }
%token UNKOWN
%token DRAW
%token <num> INTEGER
%token <string> STRING
%type <string> STR
%type <num> NUM

struct options {
	char * event_name;
	char * site_name;
	int day;
	int  month;
	int year;
	int round;
	char * white_player;
	char * black_player;
	int result;
} opts;

%%

program:
	event opts1
opts1:
	site opts2
opts2:
	date opts3
opts3:
	round opts4
opts4:
	white opts5
opts5:
	black opts6
opts6:
	result game

event:
	'[' 'E' 'v' 'e' 'n' 't' ' ' STR ']' '\n' { int len = strlen($1) - 2;
														opts.event_name = malloc(len);
														memcpy(opts.event_name, $1 + 1, len); }
site:
	'[' 'S' 'i' 't' 'e' ' ' STR ']' '\n' { int len = strlen($1) - 2;
														opts.site_name = malloc(len);
														memcpy(opts.site_name, $1 + 1, len); }
white:
	'[' 'W' 'h' 'i' 't' 'e' ' ' STR ']' '\n' { int len = strlen($1) - 2;
														opts.white_player = malloc(len);
														memcpy(opts.white_player, $1 + 1, len); }
black:
	'[' 'B' 'l' 'a' 'c' 'k' ' ' STR ']' '\n' { int len = strlen($1) - 2;
														opts.black_player = malloc(len);
														memcpy(opts.black_player, $1 + 1, len); }
date:
	'[' 'D' 'a' 't' 'e' ' ' '"' datecomp '/' datecomp '/' datecomp '"' ']' '\n' {
																				opts.day = $3; opts.month = $2; opts.year = $1;
																				if(!date_is_valid(opts)){
																					yyerror("Date is invalid!\n");
																					return YYERROR;
																				}
datecomp:
	INT		{$$ = $1;}
	| UNKNOWN	{$$ = -1;}
round:
	'[' 'R' 'o' 'u' 'n' 'd' ' ' STR ']' '\n' { int val = atoi($1 + 1);
												if(atoi == 0) {
													yyerror("Invalid round format!\n");
													return YYERROR;
												}
											}
result:
	'[' 'R' 'e' 's' 'u' 'l' 't' ' ' '"' res '"' ']' '\n' {opts.result = res;
															if(res == ERROR ) {
																yyerror("Result is invalid!\n");
																return YYERROR;
															}
														}
res:
	DRAW '-' DRAW { $$ = DRAW;}
	| INT '-' INT { $$ = get_result( $1, $2 );}

//TODO falta la gramatica de game! por ahora la hago anulable y testeemos el resto....

game:

%%

int date_is_valid ( struct options opts ) {
	
	int days[12] = { 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
	int valid = 1;
	if ( opts.month != -1 && opts.days > days[opts.month]) 
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

void yyerror(char * s){
	
	fprintf(stderr, "%s\n", s);
	return;
}

int main( void ) {
	yyparse();
	return 0;
}
