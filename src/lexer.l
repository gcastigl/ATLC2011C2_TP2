%{
#include "./logic/chess.h"
#include "y.tab.h"

#include <stdio.h>

#define OPTION_NUM 7

#define WHITE_WINS 1
#define DRAW_GAME 2
#define BLACK_WINS 3

#define EVENT_TOK 1
#define SITE_TOK 2
#define WHITE_TOK 3
#define BLACK_TOK 4

int num_opts = 0;

void yyerror(char* s);

%}

EOL           (\n|\r\n|\l\n)
WHITESPACE    ([\t ]|{EOL})
COL           [a-h]
CAPTURE       x
DOT           "."
ROW           [1-8]
PIECE         [BNRQK]
INTEGER       [0-9]+

CHECK             "+"
CHECKMATE         "#"
CROWN             "="
CASTLE_KINGSIDE   "O-O"
CASTLE_QUEENSIDE  "O-O-O"

%x SITE
%x DATE
%x WHITE
%x BLACK
%x ROUND_S
%x RESULT
%x GAME
%x GAME_PRE

%x SITE_STR
%x INITIAL_STR
%x WHITE_STR
%x BLACK_STR

TAG_EVENT_BEGIN   "[Event \""
TAG_SITE_BEGIN    "[Site \""
TAG_DATE_BEGIN    "[Date \""
TAG_ROUND_BEGIN   "[Round \""
TAG_WHITE_BEGIN   "[White \""
TAG_BLACK_BEGIN   "[Black \""
TAG_RESULT_BEGIN  "[Result \""

TAG_CONTENT     [^"?\[]+

TAG_UNKNOWN     [?]+

TAG_CLOSE       "\"]"{EOL}

RESULT_WHITE    "1-0"
RESULT_BLACK    "0-1"
RESULT_DRAW     "1/2-1/2"

%%

<INITIAL,SITE,BLACK,WHITE,RESULT>{


.			{printf("Unexpected character \"%c\"\n", *yytext );return *yytext;}

}

<INITIAL>{
    {TAG_EVENT_BEGIN} {
                        yylval.num = EVENT_TOK;
                        //printf("Begin of initial\n");
						BEGIN INITIAL_STR;
                        return (INITIAL_TOKEN);
                      }
    {TAG_CLOSE}       {
                        //printf("End of initial\n");
                        BEGIN SITE;
                        return (END_TOKEN);
                      }
}

<SITE>{
    {TAG_SITE_BEGIN}  {
                        yylval.num = SITE_TOK;
						BEGIN SITE_STR;
                        return (INITIAL_TOKEN);
                      }
    {TAG_CLOSE}       {
                        BEGIN DATE;
                        return (END_TOKEN);
                      }
}



<INITIAL_STR>{
    {TAG_CONTENT}     {
                        yylval.string = malloc(yyleng+1);
                        memcpy(yylval.string, yytext, yyleng);
                        yylval.string[yyleng] = 0;
						BEGIN INITIAL;
                        return (STRING);
                      }
{TAG_UNKNOWN}     {
                        yylval.string = NULL;
						BEGIN INITIAL;
                        return (STRING);
                      }
    
}

<SITE_STR>{
    {TAG_CONTENT}     {
                        yylval.string = malloc(yyleng+1);
                        memcpy(yylval.string, yytext, yyleng);
                        yylval.string[yyleng] = 0;
						BEGIN SITE;
                        return (STRING);
                      }
{TAG_UNKNOWN}     {
                        yylval.string = NULL;
                        //printf("Parsed date piece: %d\n", yylval.num);
						BEGIN SITE;
                        return (STRING);
                      }
    
}

<WHITE_STR>{
    {TAG_CONTENT}     {
                        yylval.string = malloc(yyleng+1);
                        memcpy(yylval.string, yytext, yyleng);
                        yylval.string[yyleng] = 0;
						BEGIN WHITE;
                        return (STRING);
                      }
{TAG_UNKNOWN}     {
                        yylval.string = NULL;
                        //printf("Parsed date piece: %d\n", yylval.num);
						BEGIN WHITE;
                        return (STRING);
                      }
    
}

<BLACK_STR>{
    {TAG_CONTENT}     {
                        yylval.string = malloc(yyleng+1);
                        memcpy(yylval.string, yytext, yyleng);
                        yylval.string[yyleng] = 0;
						BEGIN BLACK;
                        return (STRING);
                      }
{TAG_UNKNOWN}     {
                        yylval.string = NULL;
                        //printf("Parsed date piece: %d\n", yylval.num);
						BEGIN BLACK;
                        return (STRING);
                      }
    
}

<DATE>{
    {INTEGER}         {
                        yylval.num = atoi(yytext);
                       // printf("Parsed date piece: %d\n", yylval.num);
                        return (INTEGER);
                      }
    {TAG_UNKNOWN}     {
                        yylval.num = -1;
                        //printf("Parsed date piece: %d\n", yylval.num);
                        return (INTEGER);
                      }
}

<ROUND_S>{

	  {INTEGER}         {
                        yylval.num = atoi(yytext);
                       // printf("Parsed date piece: %d\n", yylval.num);
                        return (INTEGER);
                      }
    "*"     {
                        yylval.num = -1;
                        //printf("Parsed date piece: %d\n", yylval.num);
                        return (INTEGER);
                      }

	[^*]		{printf("Unexpected character \"%c\"\n", *yytext);return *yytext;}


}

<DATE>{
    {TAG_DATE_BEGIN}  {
                        return (INITIAL_DATE_TOKEN);
                      }
    {DOT}             {
                        return *yytext;
                      }
    {TAG_CLOSE}       {
                        BEGIN ROUND_S;
                        return (END_TOKEN);
                      }
	{INTEGER}         {
                        yylval.num = atoi(yytext);
                       // printf("Parsed date piece: %d\n", yylval.num);
                        return (INTEGER);
                      }
    {TAG_UNKNOWN}     {
                        yylval.num = -1;
                        //printf("Parsed date piece: %d\n", yylval.num);
                        return (INTEGER);
                      }
}

<ROUND_S>{
    {TAG_ROUND_BEGIN} {
                        return (INITIAL_ROUND_TOKEN);
                      }
    {TAG_CLOSE}       {
                        BEGIN WHITE;
                        return (END_TOKEN);
                      }
}

<WHITE>{
    {TAG_WHITE_BEGIN} {
                        yylval.num = WHITE_TOK;
						BEGIN WHITE_STR;
                        return (INITIAL_TOKEN);
                      }
    {TAG_CLOSE}       {
                        BEGIN BLACK;
                        return (END_TOKEN);
                      }
}

<BLACK>{
    {TAG_BLACK_BEGIN} {
                        yylval.num = BLACK_TOK;
						BEGIN BLACK_STR;
                        return (INITIAL_TOKEN);
                      }
    {TAG_CLOSE}       {
                        BEGIN RESULT;
                        return (END_TOKEN);
                      }
}

<RESULT>{
    {TAG_RESULT_BEGIN} {
                        return (INITIAL_RESULT_TOKEN);
                      }

    {TAG_UNKNOWN}     {
                        yylval.ch = -1;
                        return (FINALRESULT);
                      }
    {TAG_CLOSE}       {
                        BEGIN GAME_PRE;
                        return (END_TOKEN);
                      }
}

<RESULT,GAME>{
    {RESULT_WHITE}    {
                        yylval.ch = WHITE_WINS;
                        return (FINALRESULT);
                      }
    {RESULT_BLACK}    {
                        yylval.ch = BLACK_WINS;
                        return (FINALRESULT);
                      }
    {RESULT_DRAW}     {
                        yylval.ch = DRAW_GAME;
                        return (FINALRESULT);
                      }
}

<GAME_PRE>{EOL}     {
                        BEGIN GAME;
                    }

<GAME>{
    {INTEGER}{DOT}  {
                        yylval.num = atoi(yytext);
                        return (ROUND);
                    }
    {PIECE}         {
                        yylval.ch = *yytext;
                        return (PIECE);
                    }
    {COL}           {
                        yylval.ch = *yytext;
                        return (COL);
                    }
    {ROW}           {
                        yylval.num = atoi(yytext);
                        return (ROW);
                    }
    {CAPTURE}       {
                        return (CAPTURE);
                    }
    {CHECK}         {
                        return (CHECK);
                    }
    {CHECKMATE}     {
                        return (CHECKMATE);
                    }
    {CROWN}         {
                        return (CROWN);
                    }
    {CASTLE_KINGSIDE}  {
                        return (SHORTCASTLE);
                    }
    {CASTLE_QUEENSIDE} {
                        return (LONGCASTLE);
                    }
    {WHITESPACE}   {
                        return (SPACE);
                    }
	{EOL}{EOL}		{
						BEGIN INITIAL;
						return(NEXT_GAME);
					}
}


.                   {
                        printf("Found unexpected character %s\n", yytext);
						return *yytext;
					}

%%

