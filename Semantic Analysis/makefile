a.out: parsetest.o prabsyn.o tiger.tab.o lex.yy.o errormsg.o util.o symbol.o table.o absyn.o
	cc -g parsetest.o prabsyn.o tiger.tab.o lex.yy.o errormsg.o util.o symbol.o table.o absyn.o

prasetest.o: util.h errormsg.h prabsyn.h
	cc -g parsetest.c

prabsyn.o: prabsyn.c util.h symbol.h absyn.h prabsyn.h
	cc -g -c prabsyn.c

absyn.o: absyn.c absyn.h
	cc -g -c absyn.c

symbol.o: symbol.c symbol.h table.h util.h
	cc -g -c symbol.c

table.o: table.c table.h
	cc -g -c table.c

tiger.tab.o: tiger.tab.c
	cc -g -c tiger.tab.c

tiger.tab.c: tiger.y
	bison -dv tiger.y

tiger.tab.h: tiger.tab.c
	echo "tiger.tab.h was created at the same time as tiger.tab.c"

errormsg.o: errormsg.c errormsg.h util.h
	cc -g -c errormsg.c

lex.yy.o: lex.yy.c tiger.tab.h errormsg.h util.h
	cc -g -c lex.yy.c

lex.yy.c: tiger.lex
	lex tiger.lex

util.o: util.c util.h
	cc -g -c util.c

clean: 
	rm -f a.out util.o parsetest.o lex.yy.o errormsg.o tiger.tab.c tiger.tab.h tiger.tab.o
