#include "chess.h"

/** TODO: Implement these. **/
static bool (*king_movement)(struct piece*, struct movement*);
static bool (*queen_movement)(struct piece*, struct movement*);
static bool (*rook_movement)(struct piece*, struct movement*);
static bool (*bishop_movement)(struct piece*, struct movement*);
static bool (*knight_movement)(struct piece*, struct movement*);
static bool (*pawn_movement)(struct piece*, struct movement*);

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

    movement_function[1] = king_movement;
    movement_function[2] = queen_movement;
    movement_function[3] = rook_movement;
    movement_function[4] = bishop_movement;
    movement_function[5] = knight_movement;
    movement_function[6] = pawn_movement;
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
            if (movement_function[piece->type](piece, movement)) {
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
    }

    if (moved) {
        return false;
    }
    return true;
}

#endif

