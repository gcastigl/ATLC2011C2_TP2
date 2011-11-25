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

    if (movement->castle_queenside) {

        // TODO: Check logic? (no hay piezas en el medio, ni rey ni 
        // torre se movió previamente, y no le hacen jaque en algún lado
        // intermedio)

        if (movement->color == WHITE) {
            gameboard->piece[WHITE_KING]->col = 3;
            gameboard->piece[WHITE_LEFTROOK]->col = 4;
        } else {
            gameboard->piece[BLACK_KING]->col = 3;
            gameboard->piece[BLACK_LEFTROOK]->col = 4;
        }
    }
    if (movement->castle_kingside) {
        if (movement->color == WHITE) {
            gameboard->piece[WHITE_KING]->col = 7;
            gameboard->piece[WHITE_RIGHTROOK]->col = 6;
        } else {
            gameboard->piece[BLACK_KING]->col = 7;
            gameboard->piece[BLACK_RIGHTROOK]->col = 6;
        }
    }

    if (movement->castle_queenside || movement->castle_kingside) {
        frontend_process_move(gameboard, NULL, NULL);
        return false;
    }

    for (int i = 0; i < 32; i++) {

        struct piece* piece = gameboard->piece[i];
        if (piece->alive
            && piece->color == movement->color)
        {
            if (movement_function[piece->type](gameboard, piece, movement)) {
                bool move_this = true;
                
                        printf("Checkpinto 0\n");
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
                        printf("Checkpinto 1\n");

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

                        printf("Checkpinto 2\n");

                        /** Move logic **/
                        piece->row = movement->row;
                        piece->col = movement->col;

                    }
                }
            }
        }
    }
    frontend_process_move(gameboard, NULL, NULL);

    return moved;
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

static bool rook_simple(uint8 fromcol, uint8 fromrow, uint8 tocol, uint8 torow) {
    int diffcol = difference(tocol, fromcol);
    int diffrow = difference(torow, fromrow);
    if (diffcol == 0 && diffcol == 0) {
        return false;
    }
    if (diffcol != 0 && diffcol != 0) {
        return false;
    }
    return true;
}

static bool bishop_simple(uint8 fromcol, uint8 fromrow, uint8 tocol, uint8 torow) {
    int diffcol = difference(tocol, fromcol);
    int diffrow = difference(torow, fromrow);
    if (diffcol != diffrow) {
        return false;
    }
    return true;
}

static bool knight_simple(uint8 fromcol, uint8 fromrow, uint8 tocol, uint8 torow) {
    int diffcol = difference(tocol, fromcol);
    int diffrow = difference(torow, fromrow);
    bool checkmov = false;
    if ((diffcol == 2 && diffrow == 1) || (diffcol == 1 && diffrow == 2)) {
        checkmov = true;
    }
    if (checkmov == false) {
        return false;
    }

}

static bool king_simple(uint8 fromcol, uint8 fromrow, uint8 tocol, uint8 torow) {

    int diffcol = difference(tocol, fromcol);
    int diffrow = difference(torow, fromrow);
    if (diffcol > 1 || diffrow > 1) {
        return false;
    }
    if (diffcol != 1 && diffrow != 1) {
        return false;
    }
    return true;
}

static void lookforking(struct piece* piece, int* row, int* col, struct gameboard* gameboard) {
    int tolook = WHITE;
    if (piece->color == WHITE) {
        tolook = BLACK;
    }
    for (int i = 1; i<=32; i++) {
        if (gameboard->piece[i]->color == tolook && gameboard->piece[i]->type == KING) {
            *row = gameboard->piece[i]->row;
            *col = gameboard->piece[i]->col;
            return;
        }
    }
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
    if (king_simple(piece->col, piece->row, movement->col, movement->row) == false) {
        return false;
    }
    int kingrow;
    int kingcol;
    lookforking(piece, &kingrow, &kingcol, gameboard);
    if (movement->check && !king_simple(movement->col, movement->row, kingcol, kingrow)) {
        return false;
    }
    if (!movement->check && king_simple(movement->col, movement->row, kingcol, kingrow)) {
        return false;
    }

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
    if (rook_simple(piece->col, piece->row, movement->col, movement->row) == false) {
        return false;
    }   
    int kingrow;
    int kingcol;
    lookforking(piece, &kingrow, &kingcol, gameboard);
    if (movement->check && !rook_simple(movement->col, movement->row, kingcol, kingrow)) {
        return false;
    }
    if (!movement->check && rook_simple(movement->col, movement->row, kingcol, kingrow)) {
        return false;
    }
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
    if (bishop_simple(piece->col, piece->row, movement->col, movement->row) == false) {
        return false;
    }
    int kingrow;
    int kingcol;
    lookforking(piece, &kingrow, &kingcol, gameboard);
    if (movement->check && !bishop_simple(movement->col, movement->row, kingcol, kingrow)) {
        return false;
    }
    if (!movement->check && bishop_simple(movement->col, movement->row, kingcol, kingrow)) {
        return false;
    }

    return true;
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
    if (knight_simple(piece->col, piece->row, movement->col, movement->row) == false) {
        return false;
    }
    int kingrow;
    int kingcol;
    lookforking(piece, &kingrow, &kingcol, gameboard);
    if (movement->check && !knight_simple(movement->col, movement->row, kingcol, kingrow)) {
        return false;
    }
    if (!movement->check && knight_simple(movement->col, movement->row, kingcol, kingrow)) {
        return false;
    }
   
    return true;
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
    if (movement->crown_type == PAWN || movement->crown_type == KING) {
        return false;
    }
    //TODO CHECK CHECK
    int kingrow;
    int kingcol;
    lookforking(piece, &kingcol, &kingrow, gameboard);
    bool isincheck;
    switch (movement->crown_type) {
        case NONE:
            isincheck = true;
            if (difference(movement->col, kingcol) != 1) {
                isincheck = false;
            }
            if (difference(movement->row, kingrow) != 1) {
                isincheck = false;
            }
            if (piece->color == WHITE && kingrow < movement->row) {
                isincheck = false;
            }
            if (piece->color == BLACK && kingrow > movement->row) {
                isincheck = false;
            }
            if (movement->check && !isincheck) {
                return false;
            }
            if (!movement->check && isincheck) {
                return false;
            }
            break;
        case QUEEN:
            if (movement->check && !rook_simple(movement->col, movement->row, kingcol, kingrow) && 
                    !bishop_simple(movement->col, movement->row, kingcol, kingrow)) {
                return false;
            }
            if (!movement->check && (rook_simple(movement->col, movement->row, kingcol, kingrow) ||
                        bishop_simple(movement->col, movement->row, kingcol, kingrow))) {
                return false;
            }
            break;
        case BISHOP:
            if (movement->check && !bishop_simple(movement->col, movement->row, kingcol, kingrow)) {
                return false;
            }
            if (!movement->check && bishop_simple(movement->col, movement->row, kingcol, kingrow)) {
                return false;
            }
            break;
        case KNIGHT:
            if (movement->check && !knight_simple(movement->col, movement->row, kingcol, kingrow)) {
                return false;
            }
            if (!movement->check && knight_simple(movement->col, movement->row, kingcol, kingrow)) {
                return false;
            }
            break;
        case ROOK:
            if (movement->check && !rook_simple(movement->col, movement->row, kingcol, kingrow)) {
                return false;
            }
            if (!movement->check && rook_simple(movement->col, movement->row, kingcol, kingrow)) {
                return false;
            }
            break;
    }
    return true;
}

