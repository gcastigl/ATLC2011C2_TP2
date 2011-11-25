#include <stdlib.h>

#include "frontend_interface.h"
#include "chess.h"

int main() {

    initialize();
    frontend_initialize();

    struct gameboard* gameboard = new_game();

    gameboard->piece[0]->row = 3;
    gameboard->piece[1]->row = 4;
    gameboard->piece[3]->row = 5;

    frontend_process_move(gameboard, NULL, NULL);

    frontend_quit();
}

