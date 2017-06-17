%{
#ifdef PRINT
#define TOKEN(t) 		printf("Token: " #t "\n");
#define TOKEN_VALUE(t)  printf("Token: " #t " Value: %s\n", yytext);
#else
#define TOKEN(t) return(t);
#define TOKEN_VALUE(t) return(t);
#endif

#include <string.h>
extern SYMTABNODEPTR symTab[SYMTABSIZE];
extern int currentSymTabSize;
int installId(char *);
%}

delim          [ \t\n\r]
ws             {delim}+
letter         [A-Za-z]
digit          [0-9]
char_const     [']{letter}[']
identifier     {letter}({letter}|{digit})*
integer        {digit}+
real           {digit}+[.]{digit}+

%%

               int i;
               float f;

":"            TOKEN(SEPARATOR)
ENDP           TOKEN(END_PROGRAM)
"."            TOKEN(DOT)
DECLARATIONS   TOKEN(DECLARATIONS)
CODE           TOKEN(CODE)
OF             TOKEN(OF)
TYPE           TOKEN(TYPE)
";"            TOKEN(SEMICOLON)
","            TOKEN(COMMA)
CHARACTER      TOKEN(TYPE_CHARACTER)
INTEGER        TOKEN(TYPE_INTEGER)
REAL           TOKEN(TYPE_REAL)
"->"           TOKEN(ASSIGNMENT)
IF             TOKEN(IF)
THEN           TOKEN(THEN)
ELSE           TOKEN(ELSE)
ENDIF          TOKEN(END_IF)
DO             TOKEN(DO)
WHILE          TOKEN(WHILE)
ENDDO          TOKEN(END_DO)
ENDWHILE       TOKEN(END_WHILE)
FOR            TOKEN(FOR)
IS             TOKEN(IS)
BY             TOKEN(BY)
TO             TOKEN(TO)
ENDFOR         TOKEN(END_FOR)
WRITE          TOKEN(WRITE)
"("            TOKEN(OPEN_BRACKET)
")"            TOKEN(CLOSE_BRACKET)
NEWLINE        TOKEN(NEWLINE)
READ           TOKEN(READ)
NOT            TOKEN(NOT)
AND            TOKEN(AND)
OR             TOKEN(OR)
"="            TOKEN(EQUAL)
"<>"           TOKEN(NOT_EQUAL)
"<"            TOKEN(LESS_THAN)
">"            TOKEN(GREATER_THAN)
"<="           TOKEN(LESS_THAN_EQUAL)
">="           TOKEN(GREATER_THAN_EQUAL)
"+"            TOKEN(PLUS)
"-"            TOKEN(MINUS)
"*"            TOKEN(MULTIPLY)
"/"            TOKEN(DIVIDE)
{ws}           ;
{char_const}   {
                   yylval.iVal = installId(yytext);
                   TOKEN_VALUE(CHAR_CONST);
               }
{identifier}   {
                   yylval.iVal = installId(yytext);
                   TOKEN_VALUE(IDENTIFIER);
               };
{integer}      {
                   yylval.iVal = installId(yytext);
                   TOKEN_VALUE(INTEGER);
               };
{real}         {
                   yylval.iVal = installId(yytext);
                   TOKEN_VALUE(REAL);
               };

%%

/* Here is the code for the library of symbol table routines */

/* code for a simple symbol table, which is an array of pointers to
   structs, each of which contains an identifier.
*/


SYMTABNODEPTR newSymTabNode()
{
    return ((SYMTABNODEPTR)malloc(sizeof(SYMTABNODE)));
}

int lookup(char *s)
{
    extern SYMTABNODEPTR symTab[SYMTABSIZE];
    extern int currentSymTabSize;
    int i;

    for(i=0; i<currentSymTabSize; i++)
    {
        if(strncmp(s,symTab[i]->identifier,IDLENGTH) == 0)
        {
            return (i);
        }
    }
    return (-1);    
}

/* Look up an identifier in the symbol table, if its there return
   its index.  If its not there, put it in the end position,
   as long as the table isn't full, and return its index.
*/

int installId(char *id) 
{
    extern SYMTABNODEPTR symTab[SYMTABSIZE]; 
    extern int currentSymTabSize;
    int index;

    index = lookup(id);
    if (index >= 0)
    {
        return (index);
    }
    else 
       if (currentSymTabSize >= SYMTABSIZE) 
          /* SYMTAB is full */
          return (NOTHING) ;
    else
    {
       symTab[currentSymTabSize] = newSymTabNode();
       /* Recommended code for preventing buffer overrun on bounded strings */
       strncpy(symTab[currentSymTabSize]->identifier,id,IDLENGTH);
       symTab[currentSymTabSize]->identifier[IDLENGTH-1] = '\0';
       return(currentSymTabSize++);
    }
}
