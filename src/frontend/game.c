#include "chess.h"
#include "frontend_interface.h"

#include <SDL.h>
#include <SDL_image.h>

static int WIDTH = 400;
static int HEIGHT = 400;
static int DEPTH = 16;

static SDL_Surface* screen;
static SDL_Surface* buffer;

static SDL_Surface* board;
static SDL_Surface* pieces[COLORS][TOTAL_TYPES];

void frontend_initialize() {

    if (SDL_Init(SDL_INIT_VIDEO) < 0 ) return 1;
   
    if (!(screen = SDL_SetVideoMode(WIDTH, HEIGHT, DEPTH, SDL_HWSURFACE)))
    {
        SDL_Quit();
    }

    buffer = SDL_GetVideoSurface();

    board = IMG_Load("res/images/board.png");

    char path[50];
    
    strcpy(path, "res/images/piece__.png");

    for (enum color = WHITE; color <= BLACK; color++) {
        
        path[17] = color + '1';

        for (enum piece_type piece = KING; piece <= PAWN; piece++) {
            
            path[18] = piece + '0';

            pieces[color][piece] = IMG_Load(path);
        }
    }
}

static void wait_for_keypress() {

    int keypress = 0;
    SDL_Event event;
    while(!keypress) 
    {
        while(SDL_PollEvent(&event)) 
        {      
            switch (event.type) 
            {
                case SDL_QUIT:
                    SDL_Quit();
                    break;
                case SDL_KEYDOWN:
                    keypress = 1;
                    break;
            }
        }
    }
}

static void draw_gameboard(struct gameboard* gameboard) {
    

}
 
void frontend_new_game(struct gameboard* gameboard) {
  
    draw_gameboard(gameboard);
    wait_for_keypress();
}

void frontend_process_capture(struct gameboard* gameboard) {

    draw_gameboard(gameboard);
}

void frontend_process_move(struct gameboard* gameboard, struct piece* piece, struct movement* movement) {

}

void frontend_quit() {
    SDL_Quit();
}

