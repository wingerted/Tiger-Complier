#include <stdio.h>

#include "util.h"
#include "symbol.h"
#include "absyn.h"
#include "semant.h"
#include "env.h"

struct expty expTy (Tr_exp exp, Ty_ty ty)
{
  struct expty e;
  e.exp = exp;
  e.ty = ty;
  return e;
}

Ty_ty actual_ty (Ty_ty ty)
{
  while (ty && ty->kind == Ty_name) {
    ty = ty->u.name.ty;
  }

  return ty;
}

Ty_ty transTy (S_table tenv, A_ty a)
{
  switch (a->kind) {
    case A_nameTy: {
        return Ty_Name (a->u.name, S_look (tenv, a->u.name));
      }

    case A_recordTy: {
        Ty_fieldList fieldList = NULL;
        A_fieldList a_fieldList = NULL;

        for (a_fieldList = a->u.record; a_fieldList; a_fieldList = a_fieldList->tail) {
          S_symbol name = a_fieldList->head->name;
          S_symbol typ = a_fieldList->head->typ;
          //printf("%s  ", S_name (name));
          //printf("%s\n", S_name (typ));
          Ty_ty ty = S_look (tenv, typ);

          //S_enter(tenv, name, ty);
          fieldList = Ty_FieldList (Ty_Field (name, ty), fieldList);
        }

        return Ty_Record (fieldList);
      }

    case A_arrayTy: {
        return Ty_Array (S_look (tenv, a->u.array));
      }
  }

  assert (0);
}


struct expty transVar (S_table venv, S_table tenv, A_var v)
{
  switch (v->kind) {
    case A_simpleVar: {
        E_enventry x = S_look (venv, v->u.simple);

        if (x && x->kind == E_varEntry) {
          return expTy (NULL, actual_ty (x->u.var.ty));
        } else {
          EM_error (v->pos, "undefined variable %s", S_name (v->u.simple));
          return expTy (NULL, Ty_Int());
        }
      }

    case A_fieldVar: {
        struct expty var = transVar (venv, tenv, v->u.field.var);

        Ty_fieldList fList = var.ty->u.record;

        while (fList && fList->head->name != v->u.field.sym) {
          fList = fList->tail;
        }

        if (!fList) {
          EM_error (v->pos, "undefined subName %s", S_name (v->u.field.sym));
          return expTy (NULL, Ty_Int());
        } else {
          return expTy (NULL, actual_ty (fList->head->ty));
        }
      }

    case A_subscriptVar: {
        struct expty var = transVar (venv, tenv, v->u.subscript.var);
        struct expty exp = transExp (venv, tenv, v->u.subscript.exp);

        if (exp.ty->kind != Ty_int) {
          EM_error (v->pos, "subscript should be int");
          return expTy (NULL, Ty_Int());
        } else {
          return expTy (NULL, actual_ty (var.ty->u.array));
        }
      }
  }

  assert (0);
}

Ty_tyList makeFormalTyList (S_table tenv, A_fieldList params)
{
  Ty_tyList tList = NULL;
  A_fieldList pList = NULL;

  for (pList = params; pList; pList = pList->tail) {
    Ty_ty ty = S_look (tenv, pList->head->typ);
    tList = Ty_TyList (ty, tList);
  }

  return tList;
}

void transDec (S_table venv, S_table tenv, A_dec d)
{
  switch (d->kind) {
    case A_varDec: {
        Ty_ty typ = NULL;
        if (d->u.var.typ) {
          typ = S_look(tenv, d->u.var.typ);
        }

        struct expty e = transExp (venv, tenv, d->u.var.init);
        if (!typ || typ->kind == e.ty->kind) {
          if (e.ty->kind == Ty_nil && (!typ || typ->kind != Ty_record)) {
            EM_error (d->u.var.init->pos, "nil should be constrained by record");
          }
          S_enter (venv, d->u.var.var, E_VarEntry (e.ty));
        } else {
          EM_error (d->u.var.init->pos, "var type should be same as init");
        }
        break;
      }

    case A_typeDec: {
        A_nametyList nList = NULL;

        for (nList = d->u.type; nList; nList = nList->tail) {
          bool flag;
          A_nametyList scanList = NULL;
          for (scanList = nList->tail; scanList; scanList = scanList->tail) {
            if (strcmp(S_name(nList->head->name), S_name(scanList->head->name)) == 0) {
              flag = TRUE;
              break;
            }
          }
          if (flag) {
            EM_error (d->pos, "type redefined error");
          }
          S_enter(tenv, nList->head->name, Ty_Name (nList->head->ty->u.name, NULL));
        }
        for (nList = d->u.type; nList; nList = nList->tail) {
          Ty_ty waitFill = S_look(tenv, nList->head->name);
          if (waitFill->kind == Ty_name) {
            waitFill->u.name.ty = transTy (tenv, nList->head->ty);
          }
          Ty_ty trueType = actual_ty(waitFill);
          if (trueType) {
            S_enter(tenv, nList->head->name, actual_ty(waitFill));
          } else {
            EM_error (d->pos, "recursive types should through record or array");
            break;
          }

        }

        break;
      }

    case A_functionDec: {
        A_fundecList funList = NULL;

        for (funList = d->u.function; funList; funList = funList->tail) {
           bool flag;
          A_fundecList scanList = NULL;
          for (scanList = funList->tail; scanList; scanList = scanList->tail) {
            if (strcmp(S_name(funList->head->name), S_name(scanList->head->name)) == 0) {
              flag = TRUE;
              break;
            }
          }
          if (flag) {
            EM_error (d->pos, "function redefined error");
          }
          A_fundec f = funList->head;
          if (!f->result) {
            f->result = S_Symbol("void");
          }
          Ty_ty resultTy = S_look (tenv, f->result);
          Ty_tyList formalTys = makeFormalTyList (tenv, f->params);
          S_enter (venv, f->name, E_FunEntry (formalTys, resultTy));
        }
        for (funList = d->u.function; funList; funList = funList->tail) {
          A_fundec f = funList->head;
          Ty_tyList formalTys = makeFormalTyList (tenv, f->params);

          S_beginScope (venv);
          {
            A_fieldList l;
            Ty_tyList t;

            for (l = f->params, t = formalTys; l; l = l->tail, t = t->tail) {
              S_enter (venv, l->head->name, E_VarEntry (t->head));
            }
          }
          Ty_ty returnTy = S_look (tenv, f->result);
          if (returnTy->kind != transExp (venv, tenv, f->body).ty->kind) {
            EM_error (f->body->pos, "return type wrong");
          }
          S_endScope (venv);

        }

        break;
      }
  }
}

struct expty transExp (S_table venv, S_table tenv, A_exp a)
{
  switch (a->kind) {
    case A_opExp: {
        A_oper oper = a->u.op.oper;
        struct expty left = transExp (venv, tenv, a->u.op.left);
        struct expty right = transExp (venv, tenv, a->u.op.right);

        if (oper == A_plusOp || oper == A_minusOp || oper == A_timesOp || oper == A_divideOp) {
          if (left.ty->kind != Ty_int) {
            EM_error (a->u.op.left->pos, "integer required");
          }

          if (right.ty->kind != Ty_int) {
            EM_error (a->u.op.right->pos, "integer required");
          }
        } else {
          if (left.ty->kind != right.ty->kind) {
            EM_error (a->u.op.right->pos, "left type should be same as right");
          }
        }
        return expTy (NULL, Ty_Int());
      }

    case A_varExp: {
        return transVar (venv, tenv, a->u.var);
      }

    case A_nilExp: {
        return expTy (NULL, Ty_Nil());
      }

    case A_intExp: {
        return expTy (NULL, Ty_Int());
      }

    case A_stringExp: {
        return expTy (NULL, Ty_String());
      }

    case A_callExp: {
        E_enventry x = S_look (venv, a->u.call.func);

        if (x && x->kind == E_funEntry) {
          Ty_tyList tList;
          A_expList eList;

          for (tList = x->u.fun.formals, eList = a->u.call.args; tList &&  eList; tList = tList->tail, eList = eList->tail) {
            Ty_ty expTyName = transExp (venv, tenv, eList->head).ty;

            if (tList->head->kind != expTyName->kind) {
              if (tList->head->kind == Ty_record && expTyName->kind == Ty_nil) {
                continue;
              }
              EM_error (eList->head->pos, "field type is wrong");
              return expTy (NULL, Ty_Int());
            }
          }

          if (tList || eList) {
            EM_error (a->u.call.args->head->pos, "field type number is wrong");
            return expTy (NULL, Ty_Int());
          }

          return expTy (NULL, x->u.fun.result);
        }

        EM_error (a->pos, "undefined function name %s", S_name (a->u.call.func));
        return expTy (NULL, Ty_Int());
      }

    case A_recordExp: {
        Ty_ty record = S_look (tenv, a->u.record.typ);

        if (!record) {
           EM_error (a->pos, "undefined record type %s", S_name (a->u.record.typ));
           return expTy (NULL, record);
        }

        if (record->kind != Ty_record) {
          EM_error (a->pos, "type should be an record");
          return expTy (NULL, Ty_Int());
        } else {
          A_efieldList efieldList = NULL;
          Ty_fieldList fieldList = record->u.record;
          for (efieldList = a->u.record.fields; efieldList && fieldList; efieldList = efieldList->tail, fieldList = fieldList->tail) {
            Ty_ty field = actual_ty(fieldList->head->ty);
            Ty_ty expTyName = transExp (venv, tenv, efieldList->head->exp).ty;

            if (field->kind != expTyName->kind) {
              if (field->kind == Ty_record && expTyName->kind == Ty_nil) {
                continue;
              }
              EM_error (a->pos, "field type wrong");
            }
          }

          if (efieldList || fieldList) {
            EM_error (a->pos, "field number wrong");
          }

          return expTy (NULL, record);
        }
      }

    case A_arrayExp: {
        Ty_ty array = S_look (tenv, a->u.array.typ);

        if (!array) {
          EM_error (a->pos, "undefined array type %s", S_name (a->u.array.typ));
          return expTy (NULL, array);
        }

        if (array->kind != Ty_array) {
          EM_error (a->pos, "type should be an array");
          return expTy (NULL, Ty_Int());
        } else {
          if (transExp (venv, tenv, a->u.array.size).ty->kind != Ty_int) {
            EM_error (a->pos, "array size should be int");
          }
          if (transExp (venv, tenv, a->u.array.init).ty->kind != array->u.array->kind) {
            EM_error (a->pos, "array type should be same as init");
          }
          return expTy (NULL, array);
        }
      }

    case A_seqExp: {
        A_expList d;

        for (d = a->u.seq; d && d->tail; d = d->tail) {
          transExp (venv, tenv, d->head);
        }
        if (d) {
          return transExp (venv, tenv, d->head);
        } else {
          return expTy (NULL, Ty_Void());
        }
      }

    case A_assignExp: {
        transVar (venv, tenv, a->u.assign.var);
        transExp (venv, tenv, a->u.assign.exp);
        return expTy (NULL, Ty_Void());
      }

    case A_ifExp: {
        transExp (venv, tenv, a->u.iff.test);

        if (a->u.iff.elsee) {
          struct expty then = transExp (venv, tenv, a->u.iff.then);
          struct expty elsee = transExp (venv, tenv, a->u.iff.elsee);

          if (then.ty->kind != elsee.ty->kind) {
            EM_error (a->u.iff.elsee->pos, "then should be same as else");
          }

          return then;
        } else {
          struct expty then = transExp (venv, tenv, a->u.iff.then);

          if (then.ty->kind != Ty_void) {
            EM_error (a->u.iff.then->pos, "then should be void");
          }

          return expTy (NULL, Ty_Void());
        }
      }

    case A_whileExp: {
        transExp (venv, tenv, a->u.whilee.test);
        struct expty body = transExp (venv, tenv, a->u.whilee.body);

        if (body.ty->kind != Ty_void) {
          EM_error (a->u.whilee.body->pos, "body of while error, it should return void");
        }

        return expTy (NULL, Ty_Void());
      }

    case A_forExp: {
        S_enter (venv, a->u.forr.var, E_VarEntry (Ty_Int()));

        struct expty lo = transExp (venv, tenv, a->u.forr.lo);
        struct expty hi = transExp (venv, tenv, a->u.forr.hi);
        if (lo.ty->kind != Ty_int) {
          EM_error (a->u.forr.lo->pos, "lo exp of for should be int");
        }

        if (hi.ty->kind != Ty_int) {
          EM_error(a->u.forr.hi->pos, "hi exp of for should be int");
        }

        S_beginScope (venv);
        //if (a->u.forr.body->kind == A_seqExp) {
        //  A_expList test = a->u.forr.body->u.seq;
        //  while (test) {
        //    if (test->head->kind == A_assignExp) {

        //    }
        //  }
        //}

        struct expty body = transExp (venv, tenv, a->u.forr.body);

        if (body.ty->kind != Ty_void) {
          EM_error (a->u.forr.body->pos, "body of for error, it should return void");
        }
        S_endScope(venv);
        return expTy (NULL, Ty_Void());
      }

    case A_breakExp: {
        return expTy (NULL, Ty_Void());
      }

    case A_letExp: {
        struct expty exp;
        A_decList d;
        S_beginScope (venv);
        S_beginScope (tenv);

        for (d = a->u.let.decs; d; d = d->tail) {
          transDec (venv, tenv, d->head);
        }

        exp = transExp (venv, tenv, a->u.let.body);
        S_endScope (tenv);
        S_endScope (venv);
        return exp;
      }
  }

  assert (0);
}

void SEM_transProg(A_exp exp) {
  transExp(E_base_venv(), E_base_tenv(), exp);
}



