%{
#include "structs.h"
#include "y.tab.h"
#include <stdio.h>
#define OPTION_NUM 7

#define WHITE_WINS 1
#define DRAW_GAME 2
#define BLACK_WINS 3

int num_opts = 0;

void yyerror(char* s);




%}

%x GAME

%%


<INITIAL>[0-9]+	{yylval.num = atoi(yytext);return (INTEGER);	}
<INITIAL>\"[^"/\-\n]+\" {yylval.string = malloc(yyleng+1); memcpy(yylval.string, yytext, yyleng);yylval.string[yyleng] = 0;return (STRING);}
<INITIAL>"."	{return *yytext;}
<INITIAL>"\n"		{if(++num_opts == OPTION_NUM){
					printf("State Game Begun!");
					BEGIN GAME;
				}
				printf("Sume 1!");
				}
<INITIAL>"??"		{return (UNKNOWN);}
<INITIAL>[ \t]	{return *yytext;}
<INITIAL>"/"	{return *yytext;}
<INITIAL>"["	{return *yytext;}
<INITIAL>"]"	{return *yytext;}
<INITIAL>\"	{return *yytext;}
<INITIAL>"-"	{return *yytext;}
<INITIAL>[a-zA-Z]	{return *yytext;}
<INITIAL>.		{/*watisthis*/
			char msg[40];
			if(*yytext == 0)
				printf("WTFFFFF");
			sprintf(msg, "%s <%s>", "Caracter invalido!", yytext);
			yyerror(msg);
		}
<INITIAL>"1/2"	{return (DRAW);}
<GAME>[0-9]+\.	{yylval.num = atoi(yytext);return (ROUND);	}
<GAME>[BNRQK]	{yylval.ch = *yytext; return (PIECE);}
<GAME>[1-8]		{yylval.ch = *yytext; return (ROW);}
<GAME>[a-h]		{yylval.ch = *yytext; return (COL);}
<GAME>[x]		{return (CAPTURE);}
<GAME>0-0		{return (SHORTCASTLE);}
<GAME>0-0-0		{return (LONGCASTLE);}
<GAME>"+"		{return (CHECK);}
<GAME>"#"		{return (CHECKMATEMOTHERFUCKER);}
<GAME>"0-1" {yylval.ch = BLACK_WINS; return (FINALRESULT);}
<GAME>"1-0" {yylval.ch = WHITE_WINS; return (FINALRESULT);}
<GAME>"1/2-1/2"	{yylval.ch = DRAW_GAME; return (FINALRESULT);}
<GAME>"\n" {;}
<GAME>" " {return *yytext;}
<GAME>.			{/*Not parsing yet, pass*/ ; }

%%

