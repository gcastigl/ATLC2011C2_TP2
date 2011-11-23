#ifndef __frontend_interface_h
#define __frontend_interface_h

#include "chess.h"

void frontend_initialize(struct gameboard*);
void frontend_process_capture(struct gameboard*, struct piece*);
void frontend_process_move(struct gameboard*, struct piece*, struct movement*);


#endif
