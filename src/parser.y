%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "./logic/chess.h"

#define WHITE_WINS 1
#define DRAW_GAME 2
#define BLACK_WINS 3

#define EVENT_TOK 1
#define SITE_TOK 2
#define WHITE_TOK 3
#define BLACK_TOK 4

#define NOCHCK 0
#define CHCK 1
#define CHCKMATE 2

#define ERROR -1

#define YYENDERROR 1

#define MAX_ROUNDS 100

int yylex(void);
void yyerror(char * s);
struct movement * get_movement( char piece, uint8 col, uint8 row, uint8 from_col, uint8 from_row,  bool capture);
struct movement * get_castle_movement ( bool is_short);
void add_crown( struct movement * mv, enum piece_type piece );
enum piece_type get_piece_type ( char piece);
struct movement *  add_check( struct movement * mv, char val );
void set_piece_types( void ) ;
void print_move( struct movement * mv);
void assign_color ( struct movement * mv, bool is_white);
void set_move ( int round, struct movement * mv, bool is_white);
void make_moves ( struct gameboard * gb);

struct options opts;

int curr_round = 0;

void update_options( int opts, char * str);

enum piece_type piece_types[30] = {0};

struct movement * movs[MAX_ROUNDS][2] = {0};


%}

%union {
    int num;
    char ch;
    char* string;
	struct movement * mv;
}

%token <num> INITIAL_TOKEN
%token <num> INITIAL_DATE_TOKEN
%token <num> INITIAL_ROUND_TOKEN
%token <num> INITIAL_RESULT_TOKEN

%token <ch> FINALRESULT
%token <num> END_TOKEN

%token <num>    UNKNOWN
%token <num>    INTEGER
%token <ch>     DOT
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

%type <num> check

%type <string> program
%type <string> option
%type <num> game
%type <num> round;

%type <mv> normal_move;
%type <mv> move;
%type <mv> pawn_move;
%type <mv> castle;


%error-verbose

%%

program:
      option program
    | game    {;}
;

option:
      INITIAL_TOKEN STRING END_TOKEN  {
        //printf("Option");
        update_options($1, $2);
      }
    | INITIAL_DATE_TOKEN INTEGER '.' INTEGER '.' INTEGER END_TOKEN {
           int res = handle_and_verify_date($2,$4,$6);
           if(res == ERROR) {
               yyerror("Date is invalid.\n");
               return YYENDERROR;
           }
      }
    | INITIAL_RESULT_TOKEN FINALRESULT END_TOKEN {
           opts.result = $2;
      }
    | INITIAL_ROUND_TOKEN INTEGER END_TOKEN {
			
           opts.round = $2;
      }
;

game:
      round SPACE move SPACE move SPACE game {assign_color($3, true); assign_color ( $5, false); set_move( $1, $3, true); set_move($1,$5,false); }
    | round SPACE move SPACE FINALRESULT     {assign_color($3, true); set_move($1, $3, true); }
    | FINALRESULT                            {printf("Final result: %c\n", $1 + '0');}
    | {;}
    ;

round:
    ROUND               { $$ = $1; }
;

move:
      castle      check {$$ = add_check( $1, $2);}
    | normal_move check {$$ = add_check( $1, $2);}
    | pawn_move   check {$$ = add_check( $1, $2);}
;

normal_move:
      PIECE COL ROW             { $$=get_movement($1, $2, $3, 0, 0, false); }
    | PIECE CAPTURE COL ROW     { $$=get_movement($1, $3, $4, 0, 0, true);}
    | PIECE COL COL ROW         { $$=get_movement($1, $3, $4, $2, 0, false);}
    | PIECE COL CAPTURE COL ROW { $$=get_movement($1, $4, $5, $2, 0, true);}
    | PIECE ROW COL ROW         { $$=get_movement($1, $3, $4, 0, $2, false);}
    | PIECE ROW CAPTURE COL ROW { $$=get_movement($1, $4, $5, 0, $2, true);}
;

pawn_move:
      COL ROW                             {$$=get_movement('P', $1, $2, 0, 0, false);}
    | COL ROW COL ROW                     {$$=get_movement('P', $3, $4, $1, $2, true);}
    | COL CAPTURE COL ROW                 {$$=get_movement('P', $3, $4, $1, 0, true);}
    | COL ROW CAPTURE COL ROW             {$$=get_movement('P', $4, $5, $1, $2, true);}
    | COL ROW CROWN PIECE                 {$$=get_movement('P', $1, $2, 0, 0, false); add_crown($$, $4); }
    | COL CAPTURE COL ROW CROWN PIECE     {$$=get_movement('P', $3, $4, $1, 0, true); add_crown($$, $6); }
    | COL ROW CAPTURE COL ROW CROWN PIECE {$$=get_movement('P', $4, $5, $1, $2, true); add_crown($$, $7);}
    | COL ROW COL ROW CROWN PIECE         {$$=get_movement('P', $4, $5, $1, $2, true); add_crown($$, $6);}
;

castle:
      SHORTCASTLE  { $$ = get_castle_movement(true);}
    | LONGCASTLE   { $$ = get_castle_movement(false);}
;

check:
      CHECK        { $$ = CHCK; }
    | CHECKMATE    { $$ = CHCKMATE; }
    |              { $$ = NOCHCK; }
;

%%

void set_move ( int round, struct movement * mv, bool is_white ) {

	int dy = 1;
	if( is_white )
		dy = 0;
	movs[round][dy] = mv;


}

//Debugging

void print_move( struct movement * mv) {

	if(mv->color == WHITE)
		printf("White: ");
	else
		printf("Black: ");
	if(mv->castle_kingside | mv->castle_queenside){
		if(mv->castle_kingside)
			printf("Kingside Castle");
		else
			printf("Queenside Castle");
	}
	else {
		printf("Piece Type: %d, from %c %c , to %c %c ", mv->piece_type, mv->from_col == 0 ? '0': mv->from_col, mv->from_row + '0', mv->col, mv->row + '0');
		if(mv->captures)
			printf("CAPTURES ");
		if(mv->check)
			printf("CHECK ");
		if(mv->checkmate)
			printf("CHECKMATE ");
	}
	printf("\n");

}


enum piece_type get_piece_type ( char piece) {

	
	return piece_types[piece - 'A'];
}

void assign_color ( struct movement * mv, bool is_white) {

	if( is_white )
		mv->color = WHITE;
	else
		mv->color = BLACK;

}

void add_crown( struct movement * mv, enum piece_type piece ){

	mv-> crown_type = piece;

}

struct movement *  add_check( struct movement * mv, char val ) {

	switch (val) {
		case CHCK: mv->check = true;break;
		case CHCKMATE: mv->checkmate = true;break;
		default: break;
	}
	return mv;

}



struct movement * get_castle_movement ( bool is_short) {
	
	struct movement * mv = malloc(sizeof(struct movement));
	if(is_short)
		mv->castle_kingside = true;
	else
		mv->castle_queenside = true;
	return mv;

}


struct movement * get_movement( char piece, uint8 col, uint8 row, uint8 from_col, uint8 from_row,  bool capture) {
	
	enum piece_type piece_type = get_piece_type(piece);
	struct movement * mv = malloc(sizeof(struct movement));
	mv->piece_type = piece_type;
	mv->col = col;
	mv->row = row;
	mv->from_col = from_col;
	mv->from_row = from_row;
	mv->captures = capture;
	mv->castle_kingside = false;
	mv->castle_queenside = false;
	mv->check = false;
	mv->checkmate = false;
	mv->crown_type = 0;
	return mv;


}  

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

void set_piece_types( void ) {

	
	piece_types['P' - 'A'] = PAWN;
	piece_types['B' - 'A'] = BISHOP;
	piece_types['N' - 'A'] = KNIGHT;
	piece_types['R' - 'A'] = ROOK;
	piece_types['K' - 'A'] = KING;
	piece_types['Q' - 'A'] = QUEEN;
	

}

void make_moves(struct gameboard * gb) {

	int i,j;
	for( i = 1 ; ; i ++ ) {
		for( j = 0 ; j < 2 ; j ++ ) {
			if(movs[i][j] == 0)
				return;
			/*bool ret = make_move( gb , movs[i][j]);
			if(!ret){
				yyerror("Invalid move detected!");
				print_move ( movs[i][j]);
				return;
			}*/
			print_move(movs[i][j]);
		}
	}

}

int main( void ) {
	set_piece_types();
    yyparse();
	//initialize();
	//struct gameboard *gb =  new_game();
	struct gameboard * gb = NULL;
	print_options(opts);
	make_moves(gb);
    return 0;
}

