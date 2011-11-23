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

%x SITE
%x DATE
%x WHITE
%x BLACK
%x ROUND_S
%x RESULT
%x GAME

%%


<INITIAL>{
"[Event \""		{ yylval.num = EVENT_TOK; return (INITIAL_TOKEN);}
[^"\?]+				{yylval.string = malloc(yyleng+1); memcpy(yylval.string, yytext, yyleng);yylval.string[yyleng] = 0; return (STRING);}
[?]+					{yylval.string= NULL; return (STRING);}
"\"]\n"					{BEGIN SITE; return (END_TOKEN);}
}

<SITE>{
"[Site \""		{ yylval.num = SITE_TOK; return (INITIAL_TOKEN);}
[^"\?]+				{yylval.string = malloc(yyleng+1); memcpy(yylval.string, yytext, yyleng);yylval.string[yyleng] = 0; return (STRING);}
[\?]+					{yylval.string= NULL; return (STRING);}
"\"]\n"					{BEGIN DATE; return (END_TOKEN);}
}

<DATE>{
"[Date \""		{return (INITIAL_DATE_TOKEN);}
[0-9]+	{yylval.num = atoi(yytext);return (INTEGER);	}
[\?]+	{yylval.num = -1; return (INTEGER);}
"."		{return *yytext;}
"\"]\n"					{BEGIN ROUND_S; return (END_TOKEN);}

}

<ROUND_S>{
"[Round \""		{ return (INITIAL_ROUND_TOKEN);}
[0-9]+	{yylval.num = atoi(yytext);return (INTEGER);	}
[\?]+	{yylval.num = -1; return (INTEGER);}
"\"]\n"					{BEGIN WHITE; return (END_TOKEN);}

}


<WHITE>{
"[White \""		{ yylval.num = WHITE_TOK; return (INITIAL_TOKEN);}
[^"?]+				{yylval.string = malloc(yyleng+1); memcpy(yylval.string, yytext, yyleng);yylval.string[yyleng] = 0; return (STRING);}
[?]+					{yylval.string= NULL; return (STRING);}
"\"]\n"					{BEGIN BLACK; return (END_TOKEN);}
}

<BLACK>{
"[Black \""		{ yylval.num = BLACK_TOK; return (INITIAL_TOKEN);}
[^"?]+				{yylval.string = malloc(yyleng+1); memcpy(yylval.string, yytext, yyleng);yylval.string[yyleng] = 0; return (STRING);}
[?]+					{yylval.string= NULL; return (STRING);}
"\"]\n"					{BEGIN RESULT; return (END_TOKEN);}
}

<RESULT>{
"[Result \""		{return (INITIAL_RESULT_TOKEN);}
"0-1" {yylval.ch = BLACK_WINS; return (FINALRESULT);}
"1-0" {yylval.ch = WHITE_WINS; return (FINALRESULT);}
"1/2-1/2"	{yylval.ch = DRAW_GAME; return (FINALRESULT);}
[?]+	{yylval.ch = -1; return (FINALRESULT);}
"\"]\n"					{BEGIN GAME; return (END_TOKEN);}

}


<GAME>{
[0-9]+\./[ ]	{yylval.num = atoi(yytext);return (ROUND);	}
[BNRQK][a-g]/[a-gx]		{yylval.pc.piece = *yytext; yylval.pc.src.col = yytext[1]; return (PIECE);}
[BNRQK][1-8]/[a-gx]		{yylval.pc.piece = *yytext; yylval.pc.src.row = yytext[1] - '0'; return (PIECE);}
[BNRQK][a-g][1-8]/[a-gx]	{yylval.pc.piece = *yytext; yylval.pc.src.col = yytext[1];yylval.pc.src.row = yytext[2] - '0'; return (PIECE);}
[a-g]/[a-gx]				{yylval.pc.piece = 'P'; yylval.pc.src.col = yytext[0]; return (PIECE);}
[1-8]/[a-gx]				{yylval.pc.piece = 'P'; yylval.pc.src.row = yytext[0] - '0'; return (PIECE);}
[a-g][1-8]/[a-gx]			{yylval.pc.piece = 'P'; yylval.pc.src.col = yytext[0]; yylval.pc.src.row = yytext[0] - '0';return (PIECE);}
[a-g][1-8]/[ ]			{yylval.tgt.dst.col = yytext[0]; yylval.tgt.dst.row = yytext[1] - '0';
							yylval.tgt.check = 0; yylval.tgt.checkmate = 0; return (TARGET);}
[a-g][1-8][+#]			{
						yylval.tgt.dst.col = yytext[0]; yylval.tgt.dst.row = yytext[1] - '0';
						yylval.tgt.check = 0; yylval.tgt.checkmate = 0;
						if(yytext[2] == '+')
							yylval.tgt.check = 1;
						else
							yylval.tgt.checkmate = 1;
						return (TARGET);
						}
0-0		{return (SHORTCASTLE);}
0-0-0		{return (LONGCASTLE);}
"0-1" {yylval.ch = BLACK_WINS; return (FINALRESULT);}
"1-0" {yylval.ch = WHITE_WINS; return (FINALRESULT);}
"1/2-1/2"	{yylval.ch = DRAW_GAME; return (FINALRESULT);}
"\n" {;}
"x"		{return (CAPTURE);}
" " {return *yytext;}


}

%%

