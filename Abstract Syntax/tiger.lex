%{
#include <string.h>
#include "util.h"
#include "tiger.tab.h"
#include "errormsg.h"

int charPos=1;
char buf[100];
char *s;
int comment=0;

int yywrap(void)
{
 charPos=1;
 return 1;
}


void adjust(void)
{
 EM_tokPos=charPos;
 charPos+=yyleng;
}



%}

%Start STRINGS COMMENT

%%
<INITIAL>" "      {adjust(); continue;}
<INITIAL>\t       {adjust(); continue;}
<INITIAL>\n       {adjust(); EM_newline(); continue;}


<INITIAL>","      {adjust(); return COMMA;}
<INITIAL>":"      {adjust(); return COLON;}
<INITIAL>";"      {adjust(); return SEMICOLON;}
<INITIAL>"("      {adjust(); return LPAREN;}
<INITIAL>")"      {adjust(); return RPAREN;}
<INITIAL>"["      {adjust(); return LBRACK;}
<INITIAL>"]"      {adjust(); return RBRACK;}
<INITIAL>"{"      {adjust(); return LBRACE;}
<INITIAL>"}"      {adjust(); return RBRACE;}
<INITIAL>"."      {adjust(); return DOT;}
<INITIAL>"+"      {adjust(); return PLUS;}
<INITIAL>"-"      {adjust(); return MINUS;}
<INITIAL>"*"      {adjust(); return TIMES;}
<INITIAL>"/"      {adjust(); return DIVIDE;}
<INITIAL>"="      {adjust(); return EQ;}
<INITIAL>"<>"     {adjust(); return NEQ;}
<INITIAL>"<"      {adjust(); return LT;}
<INITIAL>"<="     {adjust(); return LE;}
<INITIAL>">"      {adjust(); return GT;}
<INITIAL>">="     {adjust(); return GE;}
<INITIAL>"&"      {adjust(); return AND;}
<INITIAL>"|"      {adjust(); return OR;}
<INITIAL>":="     {adjust(); return ASSIGN;}
<INITIAL>for  	  {adjust(); return FOR;}
<INITIAL>while    {adjust(); return WHILE;}
<INITIAL>to	  {adjust(); return TO;}
<INITIAL>break    {adjust(); return BREAK;}
<INITIAL>let      {adjust(); return LET;}
<INITIAL>in       {adjust(); return IN;}
<INITIAL>end      {adjust(); return END;}
<INITIAL>function {adjust(); return FUNCTION;}
<INITIAL>var      {adjust(); return VAR;}
<INITIAL>type     {adjust(); return TYPE;}
<INITIAL>array    {adjust(); return ARRAY;}
<INITIAL>if       {adjust(); return IF;}
<INITIAL>then     {adjust(); return THEN;}
<INITIAL>else     {adjust(); return ELSE;}
<INITIAL>do       {adjust(); return DO;}
<INITIAL>of       {adjust(); return OF;}
<INITIAL>nil      {adjust(); return NIL;}

<INITIAL>\"       {adjust(); BEGIN STRINGS; s = buf;}
<STRINGS>\\n      {adjust(); *s++ = '\n';}
<STRINGS>\\t      {adjust(); *s++ = '\t';}
<STRINGS>\\\"     {adjust(); *s++ = '\"';}
<STRINGS>\"       {adjust(); *s = 0; yylval.sval = String(buf); BEGIN INITIAL; return STRING;}
<STRINGS>.        {adjust(); *s++ = *yytext;}

<INITIAL>[A-Za-z]([A-Za-z]|[0-9]|_)*	{adjust(); yylval.sval=String(yytext); return ID;}
<INITIAL>[0-9]+	 			{adjust(); yylval.ival=atoi(yytext); return INT;}
<INITIAL>.	 			{adjust(); EM_error(EM_tokPos,"illegal token");}

<INITIAL>"/*"     {adjust(); BEGIN COMMENT; comment++;}
<COMMENT>"/*"     {adjust(); comment++;}
<COMMENT>"*/"     {adjust(); comment--; if (comment==0) {BEGIN INITIAL;}}
<COMMENT>.        {adjust();}
