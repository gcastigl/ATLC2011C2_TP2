#include "chess.h"

/**
 * Initialize constant data structures.
 */
void initialize() {

    amount = {0, 1, 1, 2, 2, 2, 8};

    initial_row = {1, 1, 1, 1, 1, 1, 1, 1,
                   2, 2, 2, 2, 2, 2, 2, 2,
                   8, 8, 8, 8, 8, 8, 8, 8
                   7, 7, 7, 7, 7, 7, 7, 7};

    initial_col = {4, 5, 1, 8, 3, 6, 2, 7,
                   1, 2, 3, 4, 5, 6, 7, 8,
                   4, 5, 1, 8, 3, 6, 2, 7,
                   1, 2, 3, 4, 5, 6, 7, 8};
}

/**
 * Initialize a board with 32 pieces
 */
struct gameboard* new_game() {

    struct gameboard* gameboard = (struct gameboard*) malloc(sizeof(struct gameboard));

    uint8 id = 0;
    for (enum color color = WHITE; color <= BLACK; color++) {

        for (enum piece_type type = KING; type <= PAWN; type++) {

            for (int i = 0; i < amount[type]; i++) {

                struct piece* piece = (struct piece*) malloc(sizeof(struct piece));

                piece->color = color;
                piece->alive = true;
                piece->type = type;
                piece->col = initial_col[id];
                piece->row = initial_row[id];
                piece->id = id + 1;
            }

            gameboard->piece[id++] = piece;
        }
    }

    frontend_initialize(gameboard);
}

/**
 * Process a movement in the board. Returns false if an error ocurred (ambiguous move
 * or invalid movement)
 */
bool make_move(struct gameboard* gameboard, struct movement* movement) {
    
    bool moved = false;

    /** TODO: Castling **/

    for (int i = 0; i < 32; i++) {

        struct piece* piece = gameboard->piece[i];
        if (piece->alive
            && piece->color == movement->color)
        {
            bool move_this = true;
            
            /** 
             * This series of checks are for optional movement data
             */

            if (movement->piece_type) {
                if (piece->type != movement->piece_type) {
                    move_this = false;
                }
            }
            if (move_this && movement->from_col) {
                if (movement->from_col != piece->col) {
                    move_this = false;
                }
            }
            if (move_this && movement->from_row) {
                if (movement->from_row != piece->row) {
                    move_this = false;
                }
            }

            /**
             * If the checks succeded, then this is the piece we need to move
             */
            if (move_this) {

                if (moved) {

                    /** Error: already moved with this movement **/
                    return false;

                } else {

                    moved = true;

                    /** Capture logic **/
                    if (movement->captures) {
                        for (int j = 0; j < 32; j++) if (j != i) {
                            struct piece* captured = gameboard->piece[j];

                            if (captured->alive &&
                                captured->row == movement->row &&
                                captured->col == movement->col) {
                                
                                captured->alive = false;
                            }
                        }
                        frontend_process_capture(gameboard, captured);
                    }

                    /** Crowning **/
                    if (movement->crown_type != NONE) {
                        
                        piece->type = movement->crown_type;
                    }

                    /** Move logic **/
                    frontend_process_move(gameboard, piece, movement);

                    piece->row = movement->row;
                    piece->col = movement->col;
                }
            }
        }
    }

    if (moved) {
        return false;
    }
    return true;
}

static bool movement_king(struct piece* piece, struct movement* movement) {
	return true;
}

static bool movement_queen(struct piece* piece, struct movement* movement) {
	return true;
}

static bool movement_rook(struct piece* piece, struct movement* movement) {
	return true;
}

static bool movement_bishop(struct piece* piece, struct movement* movement) {
	return true;
}

static bool movement_knight(struct piece* piece, struct movement* movement) {
	return true;
}

static bool movement_pawn(struct piece* piece, struct movement* movement) {
	return true;
}

