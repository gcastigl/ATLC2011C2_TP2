%{
#include "y.tab.h“
#include <stdio.h>


%}
%%
[0-9]+	{yylval.num = atoi(yytext);return (INTEGER);	}
[a-zA-Z]+ {yylval.string = yytext; return (STRING);
\n		{/*ignorar blancos y tabuladores*/};
[ \t]	{/*ignorar blancos y tabuladores*/};
.		{/*watisthis*/
			char msg[25];
			sprintf(msg, "%s <%s>", "Caracter invalido!", yytext);
			yyerror(msg);
		};
%%