#include <stdio.h>
#include <string.h>
#include "util.h"
#include "errormsg.h"
#include "prabsyn.h"
#include "semant.h"

extern int yyparse (void);
extern A_exp absyn_root;

void parse (string fname)
{
  EM_reset (fname);

  /* parsing worked */
  if (yyparse() == 0) {
    fprintf (stderr, "Parsing successful!\n");
    pr_exp (stdout, absyn_root, 0);
    SEM_transProg(absyn_root);
  } else {
    fprintf (stderr, "Parsing failed\n");
  }
}


int main (int argc, char **argv)
{
#if YYDEBUG
  yydebug = 1;
#endif

  //if (argc != 2) {
  //  fprintf (stderr, "usage: a.out filename\n");
  //  exit (1);
  //}

  //fprintf (stderr, "%s ,", argv[1]);

  parse("/home/wingerted/Workspace/Tiger/Testcases/Official/Bad/test17.tig");

  //parse (argv[1]);
  return 0;
}
