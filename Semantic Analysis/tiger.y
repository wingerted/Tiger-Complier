%{
#include <stdio.h>
#include "util.h"
#include "symbol.h" 
#include "errormsg.h"
#include "absyn.h"
#define YYDEBUG 1
int yylex(void); /* function prototype */

A_exp absyn_root;

void yyerror(char *s) {
  EM_error(EM_tokPos, "%s", s);
}
%}

%union {
  int pos;
  int ival;
  string sval;
  A_var var;
  A_exp exp;
  A_dec dec;
  A_ty ty;
  A_decList decList;
  A_expList expList;
  A_field field;
  A_fieldList fieldList;
  A_fundec fundec;
  A_fundecList fundecList;
  A_namety namety;
  A_nametyList nametyList;
  A_efield efield;
  A_efieldList efieldList;
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


%type <var> var var1 var2
%type <ty> ty
%type <exp> exp program
%type <expList> expList
%type <dec> dec vardec
%type <decList> decList
%type <field> field
%type <fieldList> fieldList
%type <fundec> fundec
%type <fundecList> fundecList
%type <namety> namety
%type <nametyList> nametyList
%type <efield> efield
%type <efieldList> efieldList


%start program


%right ASSIGN OF THEN ELSE DO DOT
%left OR
%left AND
%nonassoc EQ NEQ LT LE GT GE
%left PLUS MINUS
%left TIMES DIVIDE
%left UMINUS




%%

decList	:	dec {$$ = A_DecList($1, NULL);}
	|	decList dec {$$ = A_DecList($2, $1);}
	;

dec	:	nametyList {$$ = A_TypeDec(EM_tokPos, $1);}
	|	vardec {$$ = $1;}
	|	fundecList {$$ = A_FunctionDec(EM_tokPos, $1);}
	;

nametyList	:	namety {$$ = A_NametyList($1, NULL);}
		|	nametyList namety {$$ = A_NametyList($2, $1);}
		;

fundecList	:	fundec {$$ = A_FundecList($1, NULL);}
		|	fundecList fundec {$$ = A_FundecList($2, $1);}
		;

namety	:	TYPE ID EQ ty {$$ = A_Namety(S_Symbol($2), $4);}
	;

ty	:	ID {$$ = A_NameTy(EM_tokPos, S_Symbol($1));}
	|	LBRACE fieldList RBRACE {$$ = A_RecordTy(EM_tokPos, $2);}
	|	ARRAY OF ID {$$ = A_ArrayTy(EM_tokPos, S_Symbol($3));}
	;

fieldList	:	{$$ = NULL;}
		|	field {$$ = A_FieldList($1, NULL);}
		|	fieldList COMMA field {$$ = A_FieldList($3, $1);}
		;

field	:	ID COLON ID {$$ = A_Field(EM_tokPos, S_Symbol($1), S_Symbol($3));}
	;

efieldList	:	{$$ = NULL;}
		|	efield {$$ = A_EfieldList($1, NULL);}
		|	efieldList COMMA efield {$$ = A_EfieldList($3, $1);}
		;

efield	:	ID EQ exp {$$ = A_Efield(S_Symbol($1), $3);}
	;


vardec	:	VAR ID ASSIGN exp {$$ = A_VarDec(EM_tokPos, S_Symbol($2), NULL, $4);}
	|	VAR ID COLON ID ASSIGN exp {$$ = A_VarDec(EM_tokPos, S_Symbol($2), S_Symbol($4), $6);}
	;

fundec	:	FUNCTION ID LPAREN fieldList RPAREN EQ exp {$$ = A_Fundec(EM_tokPos, S_Symbol($2), $4, NULL, $7);}
	|	FUNCTION ID LPAREN fieldList RPAREN COLON ID EQ exp {$$ = A_Fundec(EM_tokPos, S_Symbol($2), $4, S_Symbol($7), $9);}
	;

var1	:	ID {$$ = A_SimpleVar(EM_tokPos, S_Symbol($1));}	
	;	

var2	:	var DOT ID {$$ = A_FieldVar(EM_tokPos, $1, S_Symbol($3));}
	|	var2 LBRACK exp RBRACK {$$ = A_SubscriptVar(EM_tokPos, $1, $3);}
	|	ID LBRACK exp RBRACK {$$ = A_SubscriptVar(EM_tokPos, A_SimpleVar(EM_tokPos, S_Symbol($1)), $3);}
	;

var 	:	var1 {$$ = $1;}
	|	var2 {$$ = $1;}
	;


program	:	exp {absyn_root=$1;}
	;

expList	:	{$$ = NULL;}
	|	exp {$$ = A_ExpList($1, NULL);}
	|	exp COMMA expList {$$ = A_ExpList($1, $3);}
	|	exp SEMICOLON expList {$$ = A_ExpList($1, $3);}
	;

exp	:	INT {$$ = A_IntExp(EM_tokPos, $1);}
	|	STRING {$$ = A_StringExp(EM_tokPos, $1);}
	|	var {$$ = A_VarExp(EM_tokPos, $1);}
	|	NIL {$$ = A_NilExp(EM_tokPos);}
	|	LPAREN expList RPAREN {$$ = A_SeqExp(EM_tokPos, $2);}
	|	ID LPAREN expList RPAREN {$$ = A_CallExp(EM_tokPos, S_Symbol($1), $3);}
	
	|	MINUS exp %prec UMINUS {$$ = A_OpExp(EM_tokPos, A_minusOp, A_IntExp(EM_tokPos, 0), $2);}
	|	exp PLUS exp {$$ = A_OpExp(EM_tokPos, A_plusOp, $1, $3);}
	|	exp MINUS exp {$$ = A_OpExp(EM_tokPos, A_minusOp, $1, $3);}
	|	exp TIMES exp {$$ = A_OpExp(EM_tokPos, A_timesOp, $1, $3);}
	|	exp DIVIDE exp {$$ = A_OpExp(EM_tokPos, A_divideOp, $1, $3);}

	|	exp AND exp {$$ = A_IfExp(EM_tokPos, $1, $3, A_IntExp(EM_tokPos, 0));}
	|	exp OR exp {$$ = A_IfExp(EM_tokPos, $1, A_IntExp(EM_tokPos, 1), $3);}
	
	|	exp EQ exp {$$ = A_OpExp(EM_tokPos, A_eqOp, $1, $3);}
	|	exp NEQ exp {$$ = A_OpExp(EM_tokPos, A_neqOp, $1, $3);}
	|	exp LT exp {$$ = A_OpExp(EM_tokPos, A_ltOp, $1, $3);}
	|	exp LE exp {$$ = A_OpExp(EM_tokPos, A_leOp, $1, $3);}
	|	exp GT exp {$$ = A_OpExp(EM_tokPos,  A_gtOp, $1, $3);}
	|	exp GE exp {$$ = A_OpExp(EM_tokPos, A_geOp, $1, $3);}

	|	ID LBRACE efieldList RBRACE {$$ = A_RecordExp(EM_tokPos, S_Symbol($1), $3);}
	
	|	ID LBRACK exp RBRACK OF exp {$$ = A_ArrayExp(EM_tokPos, S_Symbol($1), $3, $6);}
	|	var ASSIGN exp {$$ = A_AssignExp(EM_tokPos, $1, $3);}
	|	LET decList IN expList END {$$ = A_LetExp(EM_tokPos, $2, A_SeqExp(EM_tokPos, $4));}

	|	IF exp THEN exp {$$ = A_IfExp(EM_tokPos, $2, $4, NULL);}
	|	IF exp THEN exp ELSE exp {$$ = A_IfExp(EM_tokPos, $2, $4, $6);}
	|	WHILE exp DO exp {$$ = A_WhileExp(EM_tokPos, $2, $4);}
	|	FOR ID ASSIGN exp TO exp DO exp {$$ = A_ForExp(EM_tokPos, S_Symbol($2), $4, $6, $8);}
	|	BREAK {$$ = A_BreakExp(EM_tokPos);}
	;

