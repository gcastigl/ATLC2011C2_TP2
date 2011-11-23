%{
#include "y.tab.h"
#include <stdio.h>
#define OPTION_NUM 7

int num_opts = 0;

void yyerror(char* s);




%}

%x GAME

%%


<INITIAL>[0-9]+	{yylval.num = atoi(yytext);return (INTEGER);	}
<INITIAL>\"[^"/\-\n]+\" {yylval.string = malloc(yyleng+1); memcpy(yylval.string, yytext, yyleng);yylval.string[yyleng] = 0;return (STRING);}
<INITIAL>"."	{return *yytext;}
<INITIAL>\n		{if(++num_opts == OPTION_NUM)
					BEGIN(GAME);
				return *yytext;}
<INITIAL>"??"		{return (UNKNOWN);}
<INITIAL>[ \t]	{return *yytext;}
<INITIAL>"/"	{return *yytext;}
<INITIAL>"["	{return *yytext;}
<INITIAL>"]"	{return *yytext;}
<INITIAL>\"	{return *yytext;}
<INITIAL>"-"	{return *yytext;}
<INITIAL>[a-zA-Z]	{return *yytext;}
<INITIAL>.		{/*watisthis*/
			char msg[25];
			sprintf(msg, "%s <%s>", "Caracter invalido!", yytext);
			yyerror(msg);
		}
<INITIAL>"1/2"	{return (DRAW);}
<GAME>.			{/*Not parsing yet, pass*/ ; }

%%

