#include <stdio.h>

extern FILE *yyin;
int yyparse(void);

int main(int argc, char **argv)
{
#if YYDEBUG == 1
  extern int yydebug;
  yydebug = 1;
#endif

    --argc; ++argv;
    if (argc > 0)
	yyin = fopen(argv[0], "r");
    return(yyparse());
}

void yyerror(char *s)
{
    fprintf(stderr, "Error : Exiting %s\n", s);
}
