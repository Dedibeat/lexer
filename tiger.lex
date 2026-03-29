%{
#include <string.h>
#include <stdlib.h>
#include "util.h"
#include "tokens.h"
#include "errormsg.h"
int charPos = 1;
int bracketCount = 0;
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
%x COMM
%s INIT
%%
<INIT>{

    [ \t]+      { adjust(); }
    \n          { adjust(); EM_newline(); }

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

    ":="        { adjust(); return ASSIGN; }
    "<>"        { adjust(); return NEQ; }
    "<="        { adjust(); return LE; }
    ">="        { adjust(); return GE; }

    "+"         { adjust(); return PLUS; }
    "-"         { adjust(); return MINUS; }
    "*"         { adjust(); return TIMES; }
    "/"         { adjust(); return DIVIDE; }

    "="         { adjust(); return EQ; }
    "<"         { adjust(); return LT; }
    ">"         { adjust(); return GT; }

    "&"         { adjust(); return AND; }
    "|"         { adjust(); return OR; }

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

    "*/" {
        adjust();
        EM_error(EM_tokPos,"closing unopened comment");
    }

    "/*" { 
        adjust(); 
        BEGIN COMM; 
        bracketCount++;
    }

    \"([^"\\\n]|\\.)*\n {
        adjust();
        EM_error(EM_tokPos,"unterminated string");
    }

    \"([^"\\\n]|\\.)*\" {
        adjust();
        int len = yyleng - 2;
        char *s = (char*)checked_malloc(len + 1);
        int j = 0;
        for (int i = 1; i < yyleng - 1; i++) {
            if (yytext[i] == '\\') {
                i++; 
                switch (yytext[i]) {
                    case 'n':  s[j++] = '\n'; break;
                    case 't':  s[j++] = '\t'; break;
                    case 'r':  s[j++] = '\r'; break;
                    case '\\': s[j++] = '\\'; break;
                    case '"':  s[j++] = '"'; break;
                    default:
                        EM_error(EM_tokPos,"invalid escape sequence");
                        s[j++] = yytext[i];
                        break;
                }
            } else {
                s[j++] = yytext[i];
            }
        }
        s[j] = '\0';
        yylval.sval = String(s);
        return STRING;
    }

    [0-9]+ {
        adjust();
        yylval.ival = strtol(yytext, NULL, 10);
        return INT;
    }

    [a-zA-Z][a-zA-Z0-9_]* {
        adjust();
        yylval.sval = String(yytext);
        return ID;
    }

    . {
        adjust();
        EM_error(EM_tokPos,"illegal token");
    }
}

<COMM>{
    "*/" {
        adjust(); 
        bracketCount--;
        if(bracketCount < 0) 
        {
            EM_error(EM_tokPos,"closing unopened comment bracker");
        }
        if(bracketCount == 0) 
        {
            BEGIN(INIT); 
        }
    }
    "/*" { 
        adjust(); 
        BEGIN COMM; 
        bracketCount++;
    }
    \n {
        adjust();
        EM_newline();
    }
    . {   
        adjust(); 
    }
}

<COMM><<EOF>> {
    EM_error(EM_tokPos, "unclosed comment");
    return 0;
}
. {
    BEGIN(INIT);
    yyless(0);
}
<<EOF>> {
    return 0;
}

%%
