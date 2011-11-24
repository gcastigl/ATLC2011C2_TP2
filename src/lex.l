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

EOL	(\n|\r\n|\l\n)
WHITESPACE	(\n|\r\n|\l\n|[ ])
COL	[a-h]
COLORCAP	[a-fx]
ROW	[1-8]
PC	[BNRQK]

%x SITE
%x DATE
%x WHITE
%x BLACK
%x ROUND_S
%x RESULT
%x GAME
%x GAME_PRE

%%


<INITIAL>{
"[Event \""		{ yylval.num = EVENT_TOK; return (INITIAL_TOKEN);}
[^"\?]+				{yylval.string = malloc(yyleng+1); memcpy(yylval.string, yytext, yyleng);yylval.string[yyleng] = 0; return (STRING);}
[?]+					{yylval.string= NULL; return (STRING);}
"\"]"{EOL}					{BEGIN SITE; return (END_TOKEN);}
}

<SITE>{
"[Site \""		{ yylval.num = SITE_TOK; return (INITIAL_TOKEN);}
[^"\?]+				{yylval.string = malloc(yyleng+1); memcpy(yylval.string, yytext, yyleng);yylval.string[yyleng] = 0; return (STRING);}
[\?]+					{yylval.string= NULL; return (STRING);}
"\"]"{EOL}					{BEGIN DATE; return (END_TOKEN);}
}

<DATE>{
"[Date \""		{return (INITIAL_DATE_TOKEN);}
[0-9]+	{yylval.num = atoi(yytext);return (INTEGER);	}
[\?]+	{yylval.num = -1; return (INTEGER);}
"."		{return *yytext;}
"\"]"{EOL}					{BEGIN ROUND_S; return (END_TOKEN);}

}

<ROUND_S>{
"[Round \""		{ return (INITIAL_ROUND_TOKEN);}
[0-9]+	{yylval.num = atoi(yytext);return (INTEGER);	}
[\?]+	{yylval.num = -1; return (INTEGER);}
"\"]"{EOL}					{BEGIN WHITE; return (END_TOKEN);}

}


<WHITE>{
"[White \""		{ yylval.num = WHITE_TOK; return (INITIAL_TOKEN);}
[^"?]+				{yylval.string = malloc(yyleng+1); memcpy(yylval.string, yytext, yyleng);yylval.string[yyleng] = 0; return (STRING);}
[?]+					{yylval.string= NULL; return (STRING);}
"\"]"{EOL}					{BEGIN BLACK; return (END_TOKEN);}
}

<BLACK>{
"[Black \""		{ yylval.num = BLACK_TOK; return (INITIAL_TOKEN);}
[^"?]+				{yylval.string = malloc(yyleng+1); memcpy(yylval.string, yytext, yyleng);yylval.string[yyleng] = 0; return (STRING);}
[?]+					{yylval.string= NULL; return (STRING);}
"\"]"{EOL}					{BEGIN RESULT; return (END_TOKEN);}
}

<RESULT>{
"[Result \""		{return (INITIAL_RESULT_TOKEN);}
"0-1" {yylval.ch = BLACK_WINS; return (FINALRESULT);}
"1-0" {yylval.ch = WHITE_WINS; return (FINALRESULT);}
"1/2-1/2"	{yylval.ch = DRAW_GAME; return (FINALRESULT);}
[?]+	{yylval.ch = -1; return (FINALRESULT);}
"\"]"{EOL}					{BEGIN GAME_PRE; return (END_TOKEN);}

}
<GAME_PRE>{EOL}	{BEGIN GAME;}

<GAME>{
[0-9]+\./{WHITESPACE}	{yylval.num = atoi(yytext);return (ROUND);	}
{PC}/{COLORCAP}		{yylval.pc.piece = *yytext;  yylval.pc.src.col = 0; yylval.pc.src.row = 0;return (PIECE);}
{PC}{COL}/{COLORCAP}		{yylval.pc.piece = *yytext; yylval.pc.src.col = yytext[1]; yylval.pc.src.row = 0; return (PIECE);}
{PC}{ROW}/{COLORCAP}		{yylval.pc.piece = *yytext; yylval.pc.src.row = yytext[1] - '0'; yylval.pc.src.col = 0; return (PIECE);}
{PC}{COL}{ROW}/{COLORCAP}	{yylval.pc.piece = *yytext; yylval.pc.src.col = yytext[1];yylval.pc.src.row = yytext[2] - '0'; return (PIECE);}
{COL}/{COLORCAP}				{yylval.pc.piece = 'P'; yylval.pc.src.col = yytext[0]; yylval.pc.src.row = 0; return (PIECE);}
{ROW}/{COLORCAP}				{yylval.pc.piece = 'P'; yylval.pc.src.row = yytext[0] - '0'; yylval.pc.src.col = 0;return (PIECE);}
{COL}{ROW}/{COLORCAP}			{yylval.pc.piece = 'P'; yylval.pc.src.col = yytext[0]; yylval.pc.src.row = yytext[0] - '0';return (PIECE);}
{COL}{ROW}/{WHITESPACE}			{yylval.tgt.dst.col = yytext[0]; yylval.tgt.dst.row = yytext[1] - '0';
							yylval.tgt.check = 0; yylval.tgt.checkmate = 0; yylval.tgt.crowned = 0; return (TARGET);}
{COL}{ROW}[+#]			{
						yylval.tgt.dst.col = yytext[0]; yylval.tgt.dst.row = yytext[1] - '0';
						yylval.tgt.check = 0; yylval.tgt.checkmate = 0; yylval.tgt.crowned = 0;
						if(yytext[2] == '+')
							yylval.tgt.check = 1;
						else
							yylval.tgt.checkmate = 1;
						return (TARGET);
						}
{COL}{ROW}={PC}			{
						yylval.tgt.dst.col = yytext[0]; yylval.tgt.dst.row = yytext[1] - '0';
						yylval.tgt.check = 0; yylval.tgt.checkmate = 0;
						yylval.tgt.crowned = yytext[3];
						return (TARGET);
						}
"O-O"		{return (SHORTCASTLE); printf("Found short");}
"O-O-O"		{return (LONGCASTLE);}
"0-1" {yylval.ch = BLACK_WINS; return (FINALRESULT);}
"1-0" {yylval.ch = WHITE_WINS; return (FINALRESULT);}
"1/2-1/2"	{yylval.ch = DRAW_GAME; return (FINALRESULT);}
{WHITESPACE} {return (SPACE);}
"x"		{return (CAPTURE);}


}

%%

