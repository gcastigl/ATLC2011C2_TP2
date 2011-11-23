%{
#include <stdlib.h>
#include <stdio.h>

#define WHITE_WINS 1
#define DRAW 2
#define BLACK_WINS 3

#define ERROR -1

#define YYERROR 1

int yylex(void);

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

%}

%union { int num; char * string; }
%token <num> UNKNOWN
%token <num> DRAW
%token <num> INTEGER
%token <string> STRING

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
	'[' 'E' 'v' 'e' 'n' 't' ' ' STRING ']' '\n' { int len = strlen($8) - 2;
														opts.event_name = malloc(len);
														memcpy(opts.event_name, $8 + 1, len); }
	;
site:
	'[' 'S' 'i' 't' 'e' ' ' STRING ']' '\n' { int len = strlen($7) - 2;
														opts.site_name = malloc(len);
														memcpy(opts.site_name, $7 + 1, len); }
	;
white:
	'[' 'W' 'h' 'i' 't' 'e' ' ' STRING ']' '\n' { int len = strlen($8) - 2;
														opts.white_player = malloc(len);
														memcpy(opts.white_player, $8 + 1, len); }
	;
black:
	'[' 'B' 'l' 'a' 'c' 'k' ' ' STRING ']' '\n' { int len = strlen($8) - 2;
														opts.black_player = malloc(len);
														memcpy(opts.black_player, $8 + 1, len); }
	;
date:
	'[' 'D' 'a' 't' 'e' ' ' '"' datecomp '/' datecomp '/' datecomp '"' ']' '\n' {
																					opts.day = $8; opts.month = $10; opts.year = $12;
																					if(!date_is_valid(opts)){
																						yyerror("Date is invalid!\n");
																						return YYERROR;
																					}
																				}
	;
datecomp:
	INTEGER		{$$ = $1;}
	| UNKNOWN	{$$ = -1;}
	;
round:
	'[' 'R' 'o' 'u' 'n' 'd' ' ' STRING ']' '\n' { int val = atoi($8 + 1);
												if(atoi == 0) {
													yyerror("Invalid round format!\n");
													return YYERROR;
												}
											}
	;
result:
	'[' 'R' 'e' 's' 'u' 'l' 't' ' ' '"' res '"' ']' '\n' {opts.result = $10;
															if(res == ERROR ) {
																yyerror("Result is invalid!\n");
																return YYERROR;
															}
														}
	;
res:
	DRAW '-' DRAW { $$ = DRAW;}
	| INTEGER '-' INTEGER { $$ = get_result( $1, $3 );}
	;

//TODO falta la gramatica de game! por ahora la hago anulable y testeemos el resto....

game:
	;
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

//Debugging purposes

void print_options( struct options o ) {
	printf("Event: %s\n", o.event_name);
	printf("Site: %s\n", o.site_name);
	printf("White Player: %s\n", o.white_player);
	printf("Black Player: %s\n", o.black_player);
	printf("Round: %d\n", o.round);
	printf("Year: %d, Month: %d, Day: %d\n" o.year, o,month, o.days);
	printf("Result: %d\n", o.result);
	
	
}

int main( void ) {
	yyparse();
	print_options(opts);
	return 0;
}
