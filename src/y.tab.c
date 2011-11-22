%{
#include <stdlib.h>
#include <stdio.h>
int yylex(void);
%}

%union { int num; char * string; }
%token <num> INTEGER
%token <string> STRING

%%

//heres goes da grammer

%%

void yyerror(char * s){
	
	fprintf(stderr, "%s\n", s);
	return;
}

int main( void ) {
	yyparse();
	return 0;
}
