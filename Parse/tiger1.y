%{
#include <stdio.h>
#include "util.h"
#include "errormsg.h"

#define YYDEBUG 1

int yylex(void); /* function prototype */

void yyerror(char *s)
{
 EM_error(EM_tokPos, "%s", s);
}
%}


%union {
	int pos;
	int ival;
	string sval;
	}

%token <sval> ID STRING
%token <ival> INT 

%token 
  COMMA COLON SEMICOLON LPAREN RPAREN LBRACK RBRACK 
  LBRACE RBRACE DOT 
  PLUS MINUS TIMES DIVIDE EQ NEQ LT LE GT GE
  AND OR ASSIGN
  ARRAY IF THEN ELSE WHILE FOR TO DO LET IN END OF 
  BREAK NIL
  FUNCTION VAR TYPE 

%start program



%right ASSIGN OF THEN ELSE DO DOT
%left OR
%left AND
%nonassoc EQ NEQ LT LE GT GE
%left PLUS MINUS
%left TIMES DIVIDE
%left UMINUS



%%

decs	:	
	|	decs dec
	;

dec	:	tydec
	|	vardec
	|	fundec
	;

tydec	:	TYPE ID EQ ty
	;

ty	:	ID
	|	LBRACE tyfields RBRACE
	|	ARRAY OF ID
	;

tyfields	:	
		|	ID COLON ID
		|	tyfields COMMA ID COLON ID
		;

vardec	:	VAR ID ASSIGN exp
	|	VAR ID COLON ID ASSIGN exp
	;

fundec	:	FUNCTION ID LPAREN tyfields RPAREN EQ exp
	|	FUNCTION ID LPAREN tyfields RPAREN COLON ID EQ exp
	;

lvalue	:	ID
	|	lvalue DOT lvalue
	|	ID LBRACK exp RBRACK x
	;

x	:	
	|	x LBRACK exp RBRACK
	;


program	:	exp
	;

explist	:	exp
	|	explist SEMICOLON exp
	;
	
funparameters	:
		|	parameterlist
		;

parameterlist	:	exp
		|	parameterlist COMMA exp
		;

funcall	:	ID LPAREN funparameters RPAREN
	;

exp	:	INT
	|	STRING
	|	lvalue
	|	NIL
	|	LPAREN explist RPAREN
	|	LPAREN RPAREN
	|	funcall
	
	|	MINUS exp %prec UMINUS
	|	exp PLUS exp
	|	exp MINUS exp
	|	exp TIMES exp
	|	exp DIVIDE exp

	|	exp AND exp
	|	exp OR exp
	
	|	exp EQ exp
	|	exp NEQ exp
	|	exp LT exp
	|	exp LE exp
	|	exp GT exp
	|	exp GE exp

	|	record
	
	|	ID LBRACK exp RBRACK OF exp 
	|	lvalue ASSIGN exp
	|	LET decs IN expseq END

	|	IF exp THEN exp 
	|	IF exp THEN exp ELSE exp
	|	WHILE exp DO exp
	|	FOR ID ASSIGN exp TO exp DO exp
	|	BREAK
	;

domainlist	:	ID EQ exp
		|	domainlist COMMA ID EQ exp
		;

record	:	ID LBRACE RBRACE
	|	ID LBRACE domainlist RBRACE
	;

expseq	:	
	|	exp
	|	exp SEMICOLON expseq
	;

