#include "util.h"
#include "symbol.h"
#include "types.h"
#include "env.h"


E_enventry E_VarEntry (Ty_ty ty) {
  E_enventry entry = checked_malloc(sizeof(*entry));

  entry->kind = E_varEntry;
  entry->u.var.ty = ty;
  return entry;
}
E_enventry E_FunEntry (Ty_tyList formals, Ty_ty result) {

  E_enventry entry = checked_malloc(sizeof (*entry));

  entry->kind = E_funEntry;
  entry->u.fun.formals = formals;
  entry->u.fun.result = result;

  return entry;
}

S_table E_base_tenv (void) {
  S_table table = S_empty();

  S_enter(table, S_Symbol("int"), Ty_Int());
  S_enter(table, S_Symbol("nil"), Ty_Nil());
  S_enter(table, S_Symbol("string"), Ty_String());
  S_enter(table, S_Symbol("void"), Ty_Void());

  return table;
}

S_table E_base_venv (void) {
  S_table table = S_empty();
  /*
  S_enter(table, S_Symbol("print"), E_PrintFun());
  S_enter(table, S_Symbol("flush"), E_FlushFun());
  S_enter(table, S_Symbol("ord"), E_GetcharFun());
  S_enter(table, S_Symbol("chr"), E_OrdFun());
  S_enter(table, S_Symbol("size"), E_ChrFun());
  S_enter(table, S_Symbol("substring"), E_SizeFun());
  S_enter(table, S_Symbol("concat"), E_SubstringFun());
  S_enter(table, S_Symbol("not"), E_ConcatFun());
  S_enter(table, S_Symbol("exit"), E_NotFun());
  S_enter(table, S_Symbol("getchar"), E_ExitFun());
  */
  return table;
}
