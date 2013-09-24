#ifndef ENV_H_INCLUDED
#define ENV_H_INCLUDED
typedef struct E_enventry_ *E_enventry;
struct E_enventry_ {
  enum {
    E_varEntry, E_funEntry
  } kind;
  union {
    struct {
      Ty_ty ty;
    } var;
    struct {
      Ty_tyList formals;
      Ty_ty result;
    } fun;
  } u;
};

E_enventry E_VarEntry (Ty_ty ty);
E_enventry E_FunEntry (Ty_tyList formals, Ty_ty result);

E_enventry E_PrintFun(void);
E_enventry E_FlushFun(void);
E_enventry E_GetcharFun(void);
E_enventry E_OrdFun(void);
E_enventry E_ChrFun(void);
E_enventry E_SizeFun(void);
E_enventry E_SubstringFun(void);
E_enventry E_ConcatFun(void);
E_enventry E_NotFun(void);
E_enventry E_ExitFun(void);


S_table E_base_tenv (void);
S_table E_base_venv (void);


#endif // ENV_H_INCLUDED
