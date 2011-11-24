%{
#include "structs.h"
#include "bison_include.h"
#include <stdio.h>

#define OPTION_NUM 7

#define WHITE_WINS 1
#define DRAW_GAME 2
#define BLACK_WINS 3

int num_opts = 0;

void yyerror(char* s);

%}

EOL           (\n|\r\n|\l\n)
WHITESPACE    [\n\r\l ]
COL           [a-h]
CAPTURE       x
DOT           \.
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

TAG_EVENT_BEGIN   "[Event \""
TAG_SITE_BEGIN    "[Site \""
TAG_DATE_BEGIN    "[Date \""
TAG_ROUND_BEGIN   "[Round \""
TAG_WHITE_BEGIN   "[White \""
TAG_BLACK_BEGIN   "[Black \""
TAG_RESULT_BEGIN  "[Result \""

TAG_CONTENT     [^"]+

TAG_UNKNOWN     "?"

TAG_CLOSE       "\"]{EOL}"

RESULT_WHITE    "1-0"
RESULT_BLACK    "0-1"
RESULT_DRAW     "1/2-1/2"

%%


<INITIAL>{
    {TAG_EVENT_BEGIN} {
                        yylval.num = EVENT_TOK;
                        return (INITIAL_TOKEN);
                    }
    {TAG_CLOSE}       {
                        BEGIN SITE;
                        return (END_TOKEN);
                    }
}

<SITE>{
    {TAG_SITE_BEGIN} {
                        yylval.num = SITE_TOK;
                        return (SITE_TOK);
                    }
    {TAG_CLOSE}       {
                        BEGIN DATE;
                        return (END_TOKEN);
                    }
}

<INITIAL,SITE,ROUND_S,WHITE,BLACK,RESULT>{
    {TAG_CONTENT}     {
                        yylval.string = malloc(yyleng+1);
                        memcpy(yylval.string, yytext, yyleng);
                        yylval.string[yyleng] = 0;
                        return (STRING);
                    }
    {TAG_UNKNOWN}     {
                        yylval.string = NULL;
                        return (STRING);
                    }
}

<DATE,ROUND_S>{
    {INTEGER}         {
                        yylval.num = atoi(yytext);
                        return (INTEGER);
                    }
    {TAG_UNKNOWN}     {
                        yylval.num = -1;
                        return (INTEGER);
                    }
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
                        return (INITIAL_WHITE_TOKEN);
                    }
    {TAG_CLOSE}       {
                        BEGIN BLACK;
                        return (END_TOKEN);
                    }
}

<BLACK>{
    {TAG_BLACK_BEGIN} {
                        yylval.num = BLACK_TOK;
                        return (INITIAL_BLACK_TOKEN);
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
    {TAG_CLOSE}      {
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
                        yylval.piece = *yytext;
                        return (PIECE);
                    }
    {COL}           {
                        yylval.col = *yytext;
                        return (COL);
                    }
    {ROW}           {
                        yylval.row = &yytext;
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
    {WHITESPACE}    {
                        return (SPACE);
                    }
    {CAPTURE}       {
                        return (CAPTURE);
                    }
}

%%
