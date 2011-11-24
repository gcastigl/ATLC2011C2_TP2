#include <stdlib.h>

#include "frontend_interface.h"
#include "chess.h"

int main() {

    initialize();
    frontend_initialize();

    struct gameboard* gameboard = new_game();

    gameboard->piece[0]->col = 3;
    gameboard->piece[3]->col = 5;

    frontend_process_move(gameboard, NULL, NULL);

    frontend_quit();
}

