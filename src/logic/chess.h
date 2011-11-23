#ifndef __chess_h
#define __chess_h

#include "frontend_interface.h"

#define KING		1
#define QUEEN		2
#define ROOK		3
#define BISHOP		4
#define KNIGHT		5
#define PAWN		6

#define TOTAL_TYPES	7

typedef uint8 unsigned char;

typedef enum { false = 0, true } bool;

/** Types of pieces in Chess **/
enum piece_type {NONE, KING, QUEEN, ROOK, BISHOP, KNIGHT, PAWN};

/** Amount of pieces of each kind **/
uint8 amount[TOTAL_TYPES];

/** Initial row & col positions for the pieces **/
uint8 initial_row[32];

uint8 initial_col[32];

/** Colors **/
enum color {WHITE, BLACK};


/**
 * A piece in the board. It has an ID: a number from 1 to 32 included. Pieces
 * from 1 to 16 are for the white player, from 17 to 32 are black player's.
 *
 * Initially, ID 1 will be the king, ID 2 the queen, ID 3 and 4 rooks, 
 * ID 5 and 6 the white and the black bishops, 7 and 8 the knights.
 */
struct piece {

    uint8 id;
    bool alive;
    enum piece_type type;
    enum color color;
    uint8 col, row;
    // useful for PAWNS, then can move 2 steps only the first time they move.
    uint8 movments;
};

#define IS_WHITE(piece) 			(1 <= piece->id && piece->id <= 16)
#define IS_BLACK(piece) 			!(IS_WHITE(piece))

#define IS_KING(piece)				(piece->id == 1)
#define IS_QUEEN(piece)				(piece->id == 2)
#define IS_ROOK(piece)				(piece->id == 3 || piece->id == 4)

#define IS_BISHOP(piece)			(piece->id == 5 || piece->id == 6)
#define IS_BISHOP_WHITE(piece)		(piece->id == 5)
#define IS_BISHOP_BLACK(piece)		(piece->id == 6)

#define IS_KNIGHT(piece)			(piece->id == 7 || piece->id == 8)
#define IS_KNIGHT_WHITE(piece)		(piece->id == 7)
#define IS_KNIGHT_BLACK(piece)		(piece->id == 8)

/**
 * A structure describing a movement. Mandatory fields are: color, col, row.
 * The other fields are only necesary in order to solve ambiguous movements.
 */
struct movement{
    enum color color;
    uint8 col, row;

    /** Optional data **/
    enum piece_type piece_type;
    enum piece_type crown_type;
    uint8 from_col, from_row;

    /** Flags **/
    bool castle;
    bool captures;
    bool check;
    bool checkmate;
};

/**
 * This array of functions contains movement functions for all kinds of pieces.
 */
bool (*movement_function)(struct piece*, struct movement*)[7];

/** 
 * Game main class
 */
struct gameboard{

    struct piece* piece[32];
};

/**
 * Initialize a board with 32 pieces
 */
struct gameboard* new_game();

/**
 * Process a movement in the board. Returns false if an error ocurred (ambiguous move
 * or invalid movement)
 */
bool make_move(struct gameboard* gameboard, struct movement* movement);

