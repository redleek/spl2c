.SUFFIXES:

CFLAGS = -pipe

all: spl

spl.tab.c: spl.y
	bison spl.y

lex.yy.c: spl.l
	flex spl.l

spl: lex.yy.c spl.tab.c spl.c splcodegen.c
	gcc -o spl spl.c spl.tab.c -lfl $(CFLAGS)

parsetree: lex.yy.c spl.tab.c spl.c splcodegen.c
	gcc -o parsetree spl.c spl.tab.c -lfl -DDEBUG $(CFLAGS)

bisondebug: lex.yy.c spl.tab.c spl.c splcodegen.c
	gcc -o spl spl.c spl.tab.c -lfl -DYYDEBUG $(CFLAGS)

clean:
	rm -f *tab* *yy* *output spl spl.exe parsetree test_programs/*.c a.out

compiletests: clean spl
	for filename in test_programs/*; \
	do \
	    ./spl < $$filename > "$$filename.c"; \
	    gcc "$$filename.c"; \
	done
