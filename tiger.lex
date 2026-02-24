%{
#include <string.h>
#include <stdlib.h>
#include "util.h"
#include "tokens.h"
#include "errormsg.h"

int charPos = 1;

int yywrap(void)
{
    charPos = 1;
    return 1;
}

void adjust(void)
{
    EM_tokPos = charPos;
    charPos += yyleng;
}
%}

%%

    /* ---------- whitespace ---------- */

[ \t]+      { adjust(); }
\n          { adjust(); EM_newline(); }

    /* ---------- punctuation ---------- */

","         { adjust(); return COMMA; }
":"         { adjust(); return COLON; }
";"         { adjust(); return SEMICOLON; }
"("         { adjust(); return LPAREN; }
")"         { adjust(); return RPAREN; }
"["         { adjust(); return LBRACK; }
"]"         { adjust(); return RBRACK; }
"{"         { adjust(); return LBRACE; }
"}"         { adjust(); return RBRACE; }
"."         { adjust(); return DOT; }

    /* ---------- operators ---------- */

"+"         { adjust(); return PLUS; }
"-"         { adjust(); return MINUS; }
"*"         { adjust(); return TIMES; }
"/"         { adjust(); return DIVIDE; }

"="         { adjust(); return EQ; }
"<>"        { adjust(); return NEQ; }
"<="        { adjust(); return LE; }
">="        { adjust(); return GE; }
"<"         { adjust(); return LT; }
">"         { adjust(); return GT; }

"&"         { adjust(); return AND; }
"|"         { adjust(); return OR; }

":="        { adjust(); return ASSIGN; }

    /* ---------- keywords ---------- */

array       { adjust(); return ARRAY; }
if          { adjust(); return IF; }
then        { adjust(); return THEN; }
else        { adjust(); return ELSE; }
while       { adjust(); return WHILE; }
for         { adjust(); return FOR; }
to          { adjust(); return TO; }
do          { adjust(); return DO; }
let         { adjust(); return LET; }
in          { adjust(); return IN; }
end         { adjust(); return END; }
of          { adjust(); return OF; }
break       { adjust(); return BREAK; }
nil         { adjust(); return NIL; }
function    { adjust(); return FUNCTION; }
var         { adjust(); return VAR; }
type        { adjust(); return TYPE; }
    /* ---------- string ---------- */
\"([^\\\n]|\\.)*\" {
    adjust();
    int len = yyleng - 2;
    char *s = (char*)checked_malloc(sizeof(char) * (len + 1));
    strncpy(s, yytext + 1, len);
    s[len] = '\0';

    yylval.sval = String(s);
    return STRING;
}
    /* ---------- integers ---------- */

[0-9]+ {
    adjust();
    yylval.ival = atoi(yytext);
    return INT;
}

    /* ---------- identifiers ---------- */

[a-zA-Z][a-zA-Z0-9_]* {
    adjust();
    yylval.sval = String(yytext);
    return ID;
}

    /* ---------- illegal character ---------- */

. {
    adjust();
    EM_error(EM_tokPos,"illegal token");
}

%%