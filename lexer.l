%{
#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h"
%}

%option noyywrap

%%
[0-9]+      { yylval.num = atoi(yytext); return NUM; }
[-+*/()]    { return yytext[0]; }
\n          { return '\n'; }
[ \t]       { }
.           { printf("Незрозумілий символ: %s\n", yytext); }
%%