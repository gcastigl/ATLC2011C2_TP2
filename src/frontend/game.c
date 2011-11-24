#include "chess.h"
#include "frontend_interface.h"

#include <SDL/SDL.h>
#include <SDL/SDL_image.h>

static int WIDTH = 400;
static int HEIGHT = 400;
static int DEPTH = 16;
static int IMG_WIDTH=50;
static int IMG_HEIGHT=50;

static SDL_Surface* screen;

static SDL_Surface* board;
static SDL_Surface* pieces[2][TOTAL_TYPES];

void frontend_initialize() {

    if (SDL_Init(SDL_INIT_VIDEO) < 0) return;
   
    if (!(screen = SDL_SetVideoMode(WIDTH, HEIGHT, DEPTH, SDL_HWSURFACE)))
    {
        SDL_Quit();
    }

    board = IMG_Load("../res/images/board.png");

    char path[50];
    
    strcpy(path, "../res/images/piece__.png");

    for (enum color color = WHITE; color <= BLACK; color++) {
        
        path[19] = color + '1';

        for (enum piece_type piece = KING; piece <= PAWN; piece++) {
            
            path[20] = piece + '0';

            pieces[color][piece] = IMG_Load(path);

            if (pieces[color][piece] == NULL) {
                printf("Error loading piece %s\n", path);
            }
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
    
    // Override all with new board
    SDL_Rect rcDest = { 0, 0, 0, 0 };
    SDL_BlitSurface(board, NULL, screen, &rcDest);

    for (int i = 0; i < 32; i++) {

        struct piece* piece = gameboard->piece[i];

        if (piece->alive) {
            rcDest.x = (piece->col - 1) * IMG_WIDTH;
            rcDest.y = (8 - piece->row) * IMG_HEIGHT;
        }
        SDL_BlitSurface(pieces[piece->color][piece->type], NULL, screen, &rcDest);
    }
    SDL_Flip(screen);
}
 
void frontend_new_game(struct gameboard* gameboard) {
  
    draw_gameboard(gameboard);
    wait_for_keypress();
}

void frontend_process_capture(struct gameboard* gameboard, struct piece* piece) {

    // Purposely left blank.
}

void frontend_process_move(struct gameboard* gameboard, struct piece* piece, struct movement* movement) {

    // TODO: colorear la ficha que se acaba de mover
    draw_gameboard(gameboard);
    wait_for_keypress();
}

void frontend_quit() {
    SDL_Quit();
}

