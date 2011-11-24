#ifndef __frontend_interface_h
#define __frontend_interface_h

#include "chess.h"

void frontend_initialize();
void frontend_new_game(struct gameboard*);
void frontend_process_capture(struct gameboard*, struct piece*);
void frontend_process_move(struct gameboard*, struct piece*, struct movement*);
void frontend_quit();

#endif

