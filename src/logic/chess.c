#include "chess.h"
#include "frontend_interface.h"
#include <string.h>
#include <stdlib.h>

static bool king_movement(struct gameboard*, struct piece*, struct movement*);
static bool queen_movement(struct gameboard*, struct piece*, struct movement*);
static bool rook_movement(struct gameboard*, struct piece*, struct movement*);
static bool bishop_movement(struct gameboard*, struct piece*, struct movement*);
static bool knight_movement(struct gameboard*, struct piece*, struct movement*);
static bool pawn_movement(struct gameboard*, struct piece*, struct movement*);

/**
 * Initialize constant data structures.
 */
void initialize() {

    memcpy(amount, (uint8[]){0, 1, 1, 2, 2, 2, 8}, sizeof(uint8) * 7);

    memcpy(initial_row, (uint8[]) {1, 1, 1, 1, 1, 1, 1, 1,
                   2, 2, 2, 2, 2, 2, 2, 2,
                   8, 8, 8, 8, 8, 8, 8, 8,
                   7, 7, 7, 7, 7, 7, 7, 7}, sizeof(uint8) * 32);

    memcpy(initial_col, (uint8[]) {4, 5, 1, 8, 3, 6, 2, 7,
                   1, 2, 3, 4, 5, 6, 7, 8,
                   4, 5, 1, 8, 3, 6, 2, 7,
                   1, 2, 3, 4, 5, 6, 7, 8}, sizeof(uint8) * 32);
    
    movement_function[KING] = king_movement;
    movement_function[QUEEN] = queen_movement;
    movement_function[ROOK] = rook_movement;
    movement_function[BISHOP] = bishop_movement;
    movement_function[KNIGHT] = knight_movement;
    movement_function[PAWN] = pawn_movement;
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

                gameboard->piece[id++] = piece;
            }
        }
    }

    frontend_initialize();
    frontend_new_game(gameboard);

    return gameboard;
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
            if (movement_function[piece->type](gameboard, piece, movement)) {
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

                                frontend_process_capture(gameboard, captured);
                            }
                        }

                        /** Crowning **/
                        if (movement->crown_type != NONE) {
                            
                            piece->type = movement->crown_type;
                        }

                        /** Move logic **/
                        piece->row = movement->row;
                        piece->col = movement->col;

                        frontend_process_move(gameboard, piece, movement);
                    }
                }
            }
        }
    }

    if (moved) {
        return false;
    }
    return true;
}

static int difference(uint8 from, uint8 to) {
    int ans = from - to;
    if (ans < 0) {
        ans *= (-1);
    }
    return ans;
}

static bool check_valid_coordenate(uint8 col, uint8 row) {
    if (col < 1 || col > 8 || row < 1 || row > 8) {
        return false;
    }
    return true;
}

static bool check_capture(struct movement* movement, struct gameboard* gameboard) {
    if (movement->captures && movement->piece_type == NONE) {
        return false;
    }
    if (!movement->captures && movement->piece_type != NONE) {
        return false;
    }
    return true;
}

static bool king_movement(struct gameboard* gameboard, struct piece* piece, struct movement* movement) {

    if (check_valid_coordenate(movement->col, movement->row) == false) {
        return false;
    }
    if (check_capture(movement, gameboard) == false) {
        return false;
    }
    if (movement->crown_type != NONE) {
        return false;
    }
    int diffcol = difference(movement->col, piece->col);
    int diffrow = difference(movement->row, piece->row);
    if (diffcol > 1 || diffrow > 1) {
        return false;
    }
    if (diffcol != 1 && diffrow != 1) {
        return false;
    }
    //TODO CHECK CHECK
    return true;
}

static bool queen_movement(struct gameboard* gameboard, struct piece* piece, struct movement* movement) {
    return rook_movement(gameboard, piece, movement) || bishop_movement(gameboard, piece, movement);
}

static bool rook_movement(struct gameboard* gameboard, struct piece* piece, struct movement* movement) {
 	if (check_valid_coordenate(movement->col, movement->row) == false) {
        return false;
    }
    if (check_capture(movement, gameboard) == false) {
        return false;
    }
    if (movement->crown_type != NONE) {
        return false;
    }
    int diffcol = difference(movement->col, piece->col);
    int diffrow = difference(movement->row, movement->row);
    if (diffcol == 0 && diffcol == 0) {
        return false;
    }
    if (diffcol != 0 && diffcol != 0) {
        return false;
    }
    //TODO CHECK CHECK
    return true;   
}

static bool bishop_movement(struct gameboard* gameboard, struct piece* piece, struct movement* movement) {
	if (check_valid_coordenate(movement->col, movement->row) == false) {
        return false;
    }
    if (check_capture(movement, gameboard) == false) {
        return false;
    }
    if (movement->crown_type != NONE) {
        return false;
    }
    return true;
    int diffcol = difference(movement->col, piece->col);
    int diffrow = difference(movement->row, piece->row);
    if (diffcol != diffrow) {
        return false;
    }
    //TODO CHECK CHECK
}

static bool knight_movement(struct gameboard* gameboard, struct piece* piece, struct movement* movement) {
	if (check_valid_coordenate(movement->col, movement->row) == false) {
        return false;
    }
    if (check_capture(movement, gameboard) == false) {
        return false;
    }
    if (movement->crown_type != NONE) {
        return false;
    }
    return true;
    int diffcol = difference(movement->col, piece->col);
    int diffrow = difference(movement->row, piece->row);
    bool checkmov = false;
    if ((diffcol == 2 && diffrow == 1) || (diffcol == 1 && diffrow == 2)) {
        checkmov = true;
    }
    if (checkmov == false) {
        return false;
    }
    //TODO CHECK CHECK
}

static bool pawn_movement(struct gameboard* gameboard, struct piece* piece, struct movement* movement) {
	if (check_valid_coordenate(movement->col, movement->row) == false) {
        return false;
    }
    if (check_capture(movement, gameboard) == false) {
        return false;
    }
    return true;
    //CHECK IF PAWN IS GOING FORWARD
    int diffrow = piece->row - movement->row;
    if ((diffrow > 0 && piece->color == WHITE) || (diffrow < 0 && piece->color == BLACK)) {
        return false;
    }
    int diffcol = difference(movement->col, piece->col);
    diffrow = difference(movement->row, piece->row);
    bool checkmov = false;
    if (diffcol == 0 && diffrow == 1 && !movement->captures) {
        checkmov = true;
    } 
    if (diffcol == 1 && diffrow == 1 && movement->captures) {
        checkmov = true;
    }
    if (diffcol == 0 && diffrow == 2 && !movement->captures && ((piece->color == WHITE && piece->row == 2) 
                || (piece->color == BLACK && piece->row == 7))) {
        checkmov = true;
    }
    if (checkmov == false) {
        return false;
    }
    bool finalrow = false;
    if ((piece->color == WHITE && movement->row == 8) || (piece->color == BLACK && movement->row == 1)) {
        finalrow == true;
    }
    if (movement->crown_type != NONE && !finalrow) {
        return false;
    }
    if (movement->crown_type == NONE && finalrow) {
        return false;
    }
    if (movement->crown_type == PAWN) {
        return false;
    }
    //TODO CHECK CHECK
}

