#include <stdio.h>
#include <string.h>
#include "util.h"
#include "errormsg.h"

extern int yyparse(void);

void parse(string fname) 
{
  EM_reset(fname);

  /* parsing worked */
  if (yyparse() == 0) { 
    fprintf(stderr,"Parsing successful!\n");
  } else {	
    fprintf(stderr,"Parsing failed\n");
  }
}


int main(int argc, char **argv) {
  #if YYDEBUG
  yydebug = 1; 
  #endif
  
  if (argc!=2) {
    fprintf(stderr, "usage: a.out filename\n"); 
    exit(1);
  }
   
  parse(argv[1]);
  
  return 0;
}
