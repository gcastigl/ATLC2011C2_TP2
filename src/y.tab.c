%{
#include <stdlib.h>
#include <stdio.h>
int yylex(void);
%}

%union { int num; char * string; }
%token <num> INTEGER
%token <string> STRING
%type <string> STR
%type <num> NUM

struct options {
	char * event_name;
	char * site_name;
	char * date;
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
	'[' 'E' 'v' 'e' 'n' 't' ' ' '"' STR '"' ']' '\n' { int len = strlen($1);
														opts.event_name = malloc(len);
														memcpy(opts.event_name, $1, len); }
site:
	'[' 'S' 'i' 't' 'e' ' ' '"' STR '"' ']' '\n' { int len = strlen($1);
														opts.site_name = malloc(len);
														memcpy(opts.site_name, $1, len); }
white:
	'[' 'W' 'h' 'i' 't' 'e' ' ' '"' STR '"' ']' '\n' { int len = strlen($1);
														opts.white_player = malloc(len);
														memcpy(opts.white_player, $1, len); }
black:
	'[' 'B' 'l' 'a' 'c' 'k' ' ' '"' STR '"' ']' '\n' { int len = strlen($1);
														opts.black_player = malloc(len);
														memcpy(opts.black_player, $1, len); }


%%

void yyerror(char * s){
	
	fprintf(stderr, "%s\n", s);
	return;
}

int main( void ) {
	yyparse();
	return 0;
}
