%{
#include "y.tab.h“
#include <stdio.h>
#define OPTION_NUM 7

int num_opts = 0;

%s GAME
%s 

%}
%%


<INITIAL>[0-9]+	{yylval.num = atoi(yytext);return (INTEGER);	}
<INITIAL>\"[^"/-]\" + {yylval.string = yytext; return (STRING);}
<INITIAL>"."	{return **yytext;}
<INITIAL>\n		{if(++num_opts == OPTION_NUM)
					BEGIN(GAME);
				return **yytext;}
<INITIAL>??		{return (UNKNOWN);}
<INITIAL>[ \t]	{return *yytext;}
<INITIAL>/	{return *yytext;}
<INITIAL>.		{/*watisthis*/
			char msg[25];
			sprintf(msg, "%s <%s>", "Caracter invalido!", yytext);
			yyerror(msg);
		}
<INITIAL>"1/2"	{return (DRAW);}
<GAME>.			{/*Not parsing yet, pass*/ ; }

%%