#ifndef __structs_h
#define __structs_h

#define EVENT_TOK 1
#define SITE_TOK 2
#define WHITE_TOK 3
#define BLACK_TOK 4

struct options {
        char * event_name;
        char * site_name;
        int day;
        int  month;
        int year;
        int round;
        char * white_player;
        char * black_player;
        int result;
};

struct coord{
	char col;
	int row;
};

struct piece{
	char piece;
	struct coord src;
};

struct target{
	struct coord dst;
	int check;
	int checkmate;
	char crowned;
};

struct move{
	struct piece pc;
	struct target tgt;
	int shcastle;
	int lgcastle;

};

struct play{
	int round;
	struct move white;
	struct move black;
	int end;
};

#endif

