#ifndef __chess_h
#define __chess_h

#include <stdbool.h>

typedef unsigned char uint8;

#define TOTAL_TYPES	7
/** Types of pieces in Chess **/
enum piece_type {NONE = 0, KING, QUEEN, ROOK, BISHOP, KNIGHT, PAWN};

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
};

/**
 * A structure describing a movement. Mandatory fields are: color, col, row.
 * The other fields are only necesary in order to solve ambiguous movements.
 */
struct movement{
    enum color color;
    /** This is the new position that the piece should have after the movement **/
    uint8 col, row;

    /** Optional data **/
    enum piece_type piece_type;
    enum piece_type crown_type;
    uint8 from_col, from_row;

    /** Flags **/
    bool castle_queenside;
	bool castle_kingside;
    bool captures;
    bool check;
    bool checkmate;
};

/** 
 * Game main class
 */
struct gameboard{

    struct piece* piece[32];
};

void initialize();

/**
 * Initialize a board with 32 pieces
 */
struct gameboard* new_game();

/**
 * Process a movement in the board. Returns false if an error ocurred (ambiguous move
 * or invalid movement)
 */
bool make_move(struct gameboard* gameboard, struct movement* movement);

/**
 * This array of functions contains movement functions for all kinds of pieces.
 */
bool (*movement_function[TOTAL_TYPES])(struct gameboard*, struct piece*, struct movement*);

#endif

