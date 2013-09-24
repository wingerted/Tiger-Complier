#ifndef SEMANT_H_INCLUDED
#define SEMANT_H_INCLUDED
#include "types.h"


typedef void *Tr_exp;

struct expty {
  Tr_exp exp;
  Ty_ty ty;
};

struct expty expTy (Tr_exp exp, Ty_ty ty);

struct expty transVar (S_table venv, S_table tenv, A_var v);
struct expty transExp (S_table venv, S_table tenv, A_exp a);
void transDec (S_table venv, S_table tenv, A_dec d);
Ty_ty transTy (S_table tenv, A_ty a);

void SEM_transProg(A_exp exp);
#endif // SEMANT_H_INCLUDED
