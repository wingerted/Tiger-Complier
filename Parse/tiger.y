%{
#include <stdio.h>
#include "util.h"
#include "errormsg.h"

#define YYDEBUG 1
int yylex(void); /* function prototype */

void yyerror(char *s) {
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
%left LBRACK LPAREN LBRACE
%left OR
%left AND
%nonassoc EQ NEQ LT LE GT GE
%left PLUS MINUS
%left TIMES DIVIDE
%left UMINUS



%%

decList	:	dec {printf("decList\n");}
	|	decList dec{printf("decList\n");}
	;

dec	:	nametyList{printf("dec\n");}
	|	vardec{printf("dec\n");}
	|	fundecList{printf("dec\n");}
	;

nametyList	:	namety{printf("nametyList\n");}
		|	nametyList namety{printf("nametyList\n");}
		;

fundecList	:	fundec{printf("fundecList\n");}
		|	fundecList fundec{printf("fundecList\n");}
		;

namety	:	TYPE ID EQ ty{printf("namety\n");}
	;

ty	:	ID{printf("ty\n");}
	|	LBRACE fieldList RBRACE{printf("ty\n");}
	|	ARRAY OF ID{printf("ty\n");}
	;

fieldList	:	field {printf("fieldList\n");}
		|	fieldList COMMA field {printf("fieldList\n");}
		;

field	:	ID COLON ID {printf("field\n");}
	;

efieldlist	:	efield {printf("efieldList\n");}
		|	efieldlist COMMA efield {printf("efieldList\n");}
		;

efield	:	ID EQ exp {printf("efield\n");}
	;


vardec	:	VAR ID ASSIGN exp {printf("vardec\n");}
	|	VAR ID COLON ID ASSIGN exp {printf("vardec\n");}
	;

fundec	:	FUNCTION ID LPAREN fieldList RPAREN EQ exp {printf("fundec\n");}
	|	FUNCTION ID LPAREN fieldList RPAREN COLON ID EQ exp  {printf("fundec\n");}
	;

var	:	ID {printf("var\n");}
	|	var DOT ID {printf("var\n");}
	|	var LBRACK exp RBRACK {printf("var\n");}
	;

program	:	exp {printf("program\n");}
	;

explist	:	exp {printf("ecplist\n");}
	|	explist COMMA exp {printf("ecplist\n");}
	;

exp	:	INT 			{printf("exp\n");}
	|	STRING 			{printf("exp\n");}
	|	var 			{printf("exp\n");}
	|	NIL
	|	LPAREN expseq RPAREN	{printf("exp\n");}
	|	ID LPAREN explist RPAREN{printf("exp\n");}
	
	|	MINUS exp %prec UMINUS{printf("exp\n");}
	|	exp PLUS exp{printf("exp\n");}
	|	exp MINUS exp{printf("exp\n");}
	|	exp TIMES exp{printf("exp\n");}
	|	exp DIVIDE exp{printf("exp\n");}

	|	exp AND exp{printf("exp\n");}
	|	exp OR exp{printf("exp\n");}
	
	|	exp EQ exp{printf("exp\n");}
	|	exp NEQ exp{printf("exp\n");}
	|	exp LT exp{printf("exp\n");}
	|	exp LE exp{printf("exp\n");}
	|	exp GT exp{printf("exp\n");}
	|	exp GE exp{printf("exp\n");}

	|	ID LBRACE efieldlist RBRACE{printf("exp\n");}
	
	|	ID LBRACK exp RBRACK OF exp{printf("exp\n");}
	|	var ASSIGN exp{printf("exp\n");}
	|	LET decList IN expseq END{printf("exp\n");}

	|	IF exp THEN exp{printf("exp\n");}
	|	IF exp THEN exp ELSE exp{printf("exp\n");}
	|	WHILE exp DO exp{printf("exp\n");}
	|	FOR ID ASSIGN exp TO exp DO exp{printf("exp\n");}
	|	BREAK{printf("exp\n");}
	;


expseq	:	
	|	explist{printf("expseq\n");}
	|	explist SEMICOLON expseq{printf("expseq\n");}
	;

