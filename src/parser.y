%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "structs.h"

#define WHITE_WINS 1
#define DRAW_GAME 2
#define BLACK_WINS 3

#define CHCK 1
#define CHCKMATE 2

#define ERROR -1

#define YYENDERROR 1

#define MAX_ROUNDS 100

int yylex(void);
void yyerror(char * s);

struct options opts;

int curr_round = 0;

void update_options( int opts, char * str);

%}

%union {
    int num;
    char ch;
    char* string;
}

%token <num> INITIAL_TOKEN
%token <num> INITIAL_DATE_TOKEN
%token <num> INITIAL_ROUND_TOKEN
%token <num> INITIAL_RESULT_TOKEN
%token <num> INITIAL_WHITE_TOKEN
%token <num> INITIAL_BLACK_TOKEN

%token <num> FINALRESULT
%token <num> END_TOKEN

%token <num>    UNKNOWN
%token <num>    INTEGER
%token <string> STRING

%token <num> ROUND
%token <ch>  PIECE
%token <ch>  COL
%token <num> ROW

%token <ch> CAPTURE
%token <ch> CHECK
%token <ch> CHECKMATE
%token <ch> CROWN

%token <ch> SHORTCASTLE
%token <ch> LONGCASTLE

%token <ch> SPACE

%type <string> program
%type <string> option
%type <string> game
%type <string> move;
%type <string> normal_move
%type <string> pawn_move
%type <string> castle

%error-verbose

%%

program:
      option program
    | game    {;}
;

option:
      INITIAL_TOKEN STRING END_TOKEN  {
        //  return update_options($1, $2);
      }
    | INITIAL_DATE_TOKEN INTEGER '.' INTEGER '.' INTEGER END_TOKEN {
//           int res = handle_and_verify_date($2,$4,$6);
//           if(res == ERROR) {
//               yyerror("Date is invalid.\n");
//               return YYENDERROR;
//           }
      }
    | INITIAL_RESULT_TOKEN FINALRESULT END_TOKEN {
//           opts.result = $2;
      }
    | INITIAL_ROUND_TOKEN INTEGER END_TOKEN {
//           opts.round = $2;
      }
;

game:
      round SPACE move SPACE move SPACE game {;}
    | round SPACE move SPACE FINALRESULT     {;}
    | FINALRESULT                            {;}
    | {;}
    ;

round:
    ROUND               { ; }
;

move:
      castle      check {;}
    | normal_move check {;}
    | pawn_move   check {;}
;

normal_move:
      PIECE COL ROW             { ; }
    | PIECE CAPTURE COL ROW     { ;}
    | PIECE COL COL ROW         { ;}
    | PIECE COL CAPTURE COL ROW { ;}
    | PIECE ROW COL ROW         { ;}
    | PIECE ROW CAPTURE COL ROW { ;}
;

pawn_move:
      COL ROW                             {;}
    | COL CAPTURE COL ROW                 {;}
    | COL ROW CAPTURE COL ROW             {;}
    | COL ROW CROWN PIECE                 {;}
    | COL CAPTURE COL ROW CROWN PIECE     {;}
    | COL ROW CAPTURE COL ROW CROWN PIECE {;}
;

castle:
      SHORTCASTLE  { ;}
    | LONGCASTLE   { ;}
;

check:
      CHECK        { ; }
    | CHECKMATE    { ; }
    |              { ; }
;

%%

int handle_and_verify_date ( int year, int month, int day ) {
  
    int days[12] = { 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    int valid = 1;
    if ( month != -1 && day > days[month]) 
        valid = 0;
    if ( opts.month > 12 )
        valid = 0;
    if(!valid)
        return ERROR;
    opts.day = day;
    opts.month = month;
    opts.year = year;
    return 0;
  
}

void update_options(int opt, char * str) {

    char ** target;
    switch(opt) {
        case EVENT_TOK: target = &(opts.event_name);break;
        case SITE_TOK: target = &(opts.site_name);break;
        case WHITE_TOK: target = &(opts.white_player);break;
        case BLACK_TOK: target = &(opts.black_player);break;
    }
    
    int len = strlen(str) + 1;
    *target = malloc(len);
    memcpy(*target, str, len);
    free(str);
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
    printf("Year: %d, Month: %d, Day: %d\n", o.year, o.month, o.day);
    printf("Result: %d\n", o.result);
}

int main( void ) {
    yyparse();
    print_options(opts);
    return 0;
}

