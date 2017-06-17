%{
  #include <stdio.h>
  #include <stdlib.h>

  int yylex(void);
  void yyerror(char *);

  #define SYMTABSIZE  50
  #define IDLENGTH    15
  #define NOTHING     -1
  #define INDENTOFFSET 2

#ifndef TRUE
#define TRUE 0
#endif
  
#ifndef FALSE
#define FALSE 0
#endif

#ifndef NULL
#define NULL 0
#endif

  enum ParseTreeNodeType
  {
    PROGRAM,
    BLOCK,
    DECLARATION_BLOCK,
    IDENTIFIER_LIST,
    TYPE_RULE,
    STATEMENT_LIST,
    STATEMENT,
    ASSIGNMENT_STATEMENT,
    IF_STATEMENT,
    DO_STATEMENT,
    WHILE_STATEMENT,
    FOR_STATEMENT,
    WRITE_STATEMENT,
    READ_STATEMENT,
    OUTPUT_LIST,
    CONDITION,
    CONDITIONAL,
    EXPRESSION,
    COMPARATOR,
    TERM,
    VALUE,
    CONSTANT,
    NUMBER_CONSTANT,
    REAL_CONSTANT,
    INTEGER_CONSTANT,
    MINUS_REAL_CONSTANT,
    MINUS_INTEGER_CONSTANT
  };

  // For printing names of nodes
  char *NodeName[] = {"PROGRAM", "BLOCK", "DECLARATION_BLOCK",
		      "IDENTIFIER_LIST", "TYPE_RULE", "STATEMENT_LIST",
		      "STATEMENT", "ASSIGNMENT_STATEMENT", "IF_STATEMENT",
		      "DO_STATEMENT", "WHILE_STATEMENT", "FOR_STATEMENT",
		      "WRITE_STATEMENT", "READ_STATEMENT", "OUTPUT_LIST",
		      "CONDITION", "CONDITIONAL", "EXPRESSION", "COMPARATOR",
		      "TERM", "VALUE", "CONSTANT", "NUMBER_CONSTANT", "REAL_CONSTANT",
                      "INTEGER_CONSTANT", "MINUS_REAL_CONSTANT", "MINUS_INTEGER_CONSTANT"};

  // Parse tree definition
  struct treeNode {
    int  item;
    int  nodeIdentifier;
    struct treeNode *first;
    struct treeNode *second;
    struct treeNode *third;
  };
  
  typedef  struct treeNode TREE_NODE;
  typedef  TREE_NODE        *TERNARY_TREE;

  // Forward declarations
  void PrintItem(TERNARY_TREE);
  void PrintTree(TERNARY_TREE, int);
  int getType(TERNARY_TREE);
  void MatchTypes(TERNARY_TREE);
  void SplToC(TERNARY_TREE, int);
  TERNARY_TREE create_node(int,int,TERNARY_TREE,TERNARY_TREE,TERNARY_TREE);
  void yyerror(char *);
  int yylex(void);

  // Symbol table definition
  struct symTabNode {
    char identifier[IDLENGTH];
    int type;
  };
  
  typedef  struct symTabNode SYMTABNODE;
  typedef  SYMTABNODE        *SYMTABNODEPTR;
  
  SYMTABNODEPTR  symTab[SYMTABSIZE]; 
  
  int currentSymTabSize = 0;
%}

%union {
    int iVal;
    TERNARY_TREE  tVal;
}

%start program

%token SEPARATOR END_PROGRAM DOT CODE DECLARATIONS OF TYPE SEMICOLON COMMA
       TYPE_CHARACTER TYPE_INTEGER TYPE_REAL ASSIGNMENT IF THEN ELSE END_IF
       DO WHILE END_DO END_WHILE FOR IS BY TO END_FOR WRITE OPEN_BRACKET
       CLOSE_BRACKET NEWLINE READ NOT AND OR EQUAL NOT_EQUAL LESS_THAN
       GREATER_THAN LESS_THAN_EQUAL GREATER_THAN_EQUAL PLUS MINUS MULTIPLY
       DIVIDE

%token<iVal> CHAR_CONST IDENTIFIER INTEGER REAL

%type<tVal> program block declaration_block identifier_list type statement_list
             statement assignment_statement if_statement do_statement
             while_statement for_statement write_statement read_statement
             output_list condition conditional comparator expression term value
             constant number_constant

%%

program : IDENTIFIER SEPARATOR block END_PROGRAM IDENTIFIER DOT
          {
	    TERNARY_TREE ParseTree;
	    if ($1 != $5)
	      yyerror("Program names do not match");
	    ParseTree = create_node($1, PROGRAM, $3, NULL, NULL);
	    #ifdef DEBUG
	    PrintTree(ParseTree, 0);
	    #else
	    MatchTypes(ParseTree);
	    SplToC(ParseTree, 0);
	    #endif
          }
	;
block : DECLARATIONS declaration_block CODE statement_list
        {
	  $$ = create_node(NOTHING, BLOCK, $2, $4, NULL);
	}
	  | CODE statement_list
        {
	  $$ = create_node(NOTHING, BLOCK, $2, NULL, NULL);
	}
	  ;
declaration_block : identifier_list OF TYPE type SEMICOLON declaration_block
                    {
		      $$ = create_node(NOTHING, DECLARATION_BLOCK, $1, $4, $6);
		    }
		    | identifier_list OF TYPE type SEMICOLON
		    {
		      $$ = create_node(NOTHING, DECLARATION_BLOCK, $1, $4, NULL);
		    }
		    ;
identifier_list : IDENTIFIER COMMA identifier_list
                  {
		    $$ = create_node($1, IDENTIFIER_LIST, $3, NULL, NULL);
		  }
		  | IDENTIFIER
		  {
		    $$ = create_node($1, IDENTIFIER_LIST, NULL, NULL, NULL);
		  }
		  ;
type : TYPE_CHARACTER
       {
	 $$ = create_node(TYPE_CHARACTER, TYPE_RULE, NULL, NULL, NULL);
       }
       | TYPE_INTEGER
       {
	 $$ = create_node(TYPE_INTEGER, TYPE_RULE, NULL, NULL, NULL);
       }
       | TYPE_REAL
       {
	 $$ = create_node(TYPE_REAL, TYPE_RULE, NULL, NULL, NULL);
       }
       ;
statement_list : statement SEMICOLON statement_list
                 {
		   $$ = create_node(NOTHING, STATEMENT_LIST, $1, $3, NULL);
		 }
		 | statement
		 {
		   $$ = create_node(NOTHING, STATEMENT_LIST, $1, NULL, NULL);
		 }
		 ;
statement : assignment_statement
            {
	      $$ = create_node(ASSIGNMENT_STATEMENT, STATEMENT, $1, NULL, NULL);
	    }
	    | if_statement
	    {
	      $$ = create_node(IF_STATEMENT, STATEMENT, $1, NULL, NULL);
	    }
	    | do_statement
	    {
	      $$ = create_node(DO_STATEMENT, STATEMENT, $1, NULL, NULL);
	    }
	    | while_statement
	    {
	      $$ = create_node(WHILE_STATEMENT, STATEMENT, $1, NULL, NULL);
	    }
	    | for_statement
	    {
	      $$ = create_node(FOR_STATEMENT, STATEMENT, $1, NULL, NULL);
	    }
	    | write_statement
	    {
	      $$ = create_node(WRITE_STATEMENT, STATEMENT, $1, NULL, NULL);
	    }
	    | read_statement
	    {
	      $$ = create_node(READ_STATEMENT, STATEMENT, $1, NULL, NULL);
	    }
	    ;
assignment_statement : expression ASSIGNMENT IDENTIFIER
                       {
			 $$ = create_node($3, ASSIGNMENT_STATEMENT, $1, NULL, NULL);
		       }
		     ;
if_statement : IF conditional THEN statement_list
	       	   ELSE statement_list END_IF
               {
		 $$ = create_node(NOTHING, IF_STATEMENT, $2, $4, $6);
	       }
	       | IF conditional THEN statement_list END_IF
	       {
		 $$ = create_node(NOTHING, IF_STATEMENT, $2, $4, NULL);
	       }
	       ;
do_statement : DO statement_list WHILE conditional END_DO
               {
		 $$ = create_node(NOTHING, DO_STATEMENT, $2, $4, NULL);
	       }
	     ;
while_statement : WHILE conditional DO statement_list END_WHILE
                  {
		    $$ = create_node(NOTHING, WHILE_STATEMENT, $2, $4, NULL);
		  }
		;
for_statement : FOR IDENTIFIER IS expression BY expression
		TO expression DO statement_list END_FOR
                {
		 	    
		  $$ = create_node($2, FOR_STATEMENT, $4, $6,
			    create_node(NOTHING, FOR_STATEMENT, $8, $10, NULL));
		}
		;
write_statement : WRITE OPEN_BRACKET output_list CLOSE_BRACKET
                  {
		    $$ = create_node(NOTHING, WRITE_STATEMENT, $3, NULL, NULL);
		  }
		  | NEWLINE
		  {
		    $$ = create_node(NEWLINE, WRITE_STATEMENT, NULL, NULL, NULL);
		  }
		  ;
read_statement : READ OPEN_BRACKET IDENTIFIER CLOSE_BRACKET
                 {
		   $$ = create_node($3, READ_STATEMENT, NULL, NULL, NULL);
		 }
	       ;
output_list : value COMMA output_list
              {
		$$ = create_node(NOTHING, OUTPUT_LIST, $1, $3, NULL);
	      }
	      | value
	      {
		$$ = create_node(NOTHING, OUTPUT_LIST, $1, NULL, NULL);
	      }
	      ;
condition : expression comparator expression
            {
	      $$ = create_node(NOTHING, CONDITION, $1, $2, $3);
	    }
            | NOT condition
	    {
	      $$ = create_node(NOT, CONDITION, $2, NULL, NULL);
	    }
	    ;

conditional : condition
              {
		$$ = create_node(NOTHING, CONDITIONAL, $1, NULL, NULL);
	      }
	      | condition AND conditional
	      {
		$$ = create_node(AND, CONDITIONAL, $1, $3, NULL);
	      }
	      | condition OR conditional
	      {
		$$ = create_node(OR, CONDITIONAL, $1, $3, NULL);
	      }
	      ;
comparator : EQUAL
             {
	       $$ = create_node(EQUAL, COMPARATOR, NULL, NULL, NULL);
	     }
	     | NOT_EQUAL
	     {
	       $$ = create_node(NOT_EQUAL, COMPARATOR, NULL, NULL, NULL);
	     }
	     | LESS_THAN
	     {
	       $$ = create_node(LESS_THAN, COMPARATOR, NULL, NULL, NULL);
	     }
	     | GREATER_THAN
	     {
	       $$ = create_node(GREATER_THAN, COMPARATOR, NULL, NULL, NULL);
	     }
	     | LESS_THAN_EQUAL
	     {
	       $$ = create_node(LESS_THAN_EQUAL, COMPARATOR, NULL, NULL, NULL);
	     }
	     | GREATER_THAN_EQUAL
	     {
	       $$ = create_node(GREATER_THAN_EQUAL, COMPARATOR, NULL, NULL, NULL);
	     }
	     ;
expression : term PLUS expression
             {
	       $$ = create_node(PLUS, EXPRESSION, $1, $3, NULL);
	     }
	     | term MINUS expression
	     {
	       $$ = create_node(MINUS, EXPRESSION, $1, $3, NULL);
	     }
	     | term
	     {
	       $$ = create_node(NOTHING, EXPRESSION, $1, NULL, NULL);
	     }
	     ;
term : value MULTIPLY term
       {
	 $$ = create_node(MULTIPLY, TERM, $1, $3, NULL);
       }
       | value DIVIDE term
       {
	 $$ = create_node(DIVIDE, TERM, $1, $3, NULL);
       }
       | value
       {
	 $$ = create_node(NOTHING, TERM, $1, NULL, NULL);
       }
       ;
value : IDENTIFIER
        {
	  $$ = create_node($1, VALUE, NULL, NULL, NULL);
	}
	| constant
	{
	  $$ = create_node(NOTHING, VALUE, $1, NULL, NULL);
	}
	| OPEN_BRACKET expression CLOSE_BRACKET
	{
	  $$ = create_node(EXPRESSION, VALUE, $2, NULL, NULL);
	}
	;
constant : number_constant
           {
	     $$ = create_node(NOTHING, CONSTANT, $1, NULL, NULL);
	   }
	   | CHAR_CONST
	   {
	     $$ = create_node($1, CONSTANT, NULL, NULL, NULL);
	   }
	   ;
number_constant : REAL
		  {
		    $$ = create_node($1, REAL_CONSTANT, NULL, NULL, NULL);
		  }
		  | INTEGER
		  {
		    $$ = create_node($1, INTEGER_CONSTANT, NULL, NULL, NULL);
		  }
                  | MINUS REAL
		  {
		    $$ = create_node($2, MINUS_REAL_CONSTANT, NULL, NULL, NULL);
		  }
                  | MINUS INTEGER
		  {
		    $$ = create_node($2, MINUS_INTEGER_CONSTANT, NULL, NULL, NULL);
		  }
		  ;

%%

// TODO: make this method get information from symbol table
const char text[] = "Item: ";
void PrintItem(TERNARY_TREE t)
{
  switch (t->nodeIdentifier)
    {
    case FOR_STATEMENT:
      if (t->item != NOTHING)
	printf("%s%s", text, symTab[t->item]->identifier);
      break;
    case IDENTIFIER_LIST:
      printf("%s%s", text, symTab[t->item]->identifier);
      break;
    case VALUE:
      if (t->first == NULL)
	printf("%s%s", text, symTab[t->item]->identifier);
      break;
    case CONSTANT:
      if (t->first == NULL)
	printf("%s%s", text, symTab[t->item]->identifier);
      break;
    case INTEGER_CONSTANT:
    case MINUS_INTEGER_CONSTANT:
      printf("%s%s%d", text, (t->nodeIdentifier == MINUS_INTEGER_CONSTANT ? "-" : ""),
	     atoi(symTab[t->item]->identifier));
      break;
    case REAL_CONSTANT:
    case MINUS_REAL_CONSTANT:
      printf("%s%s%f", text, (t->nodeIdentifier == MINUS_REAL_CONSTANT ? "-" : ""),
	     atof(symTab[t->item]->identifier));
      break;
    default:
      
      break;
    }
}

int getType(TERNARY_TREE t)
{
  int type;
  switch (t->second->item) // type rule item
    {
    case TYPE_CHARACTER:
      type = TYPE_CHARACTER;
      break;
    case TYPE_INTEGER:
      type = TYPE_INTEGER;
      break;
    case TYPE_REAL:
      type = TYPE_REAL;
      break;
    }
  return type;
}

// Installs variable type in symbol table
void MatchTypes(TERNARY_TREE t)
{
  if (t == NULL) return;
  t = t->first->first;
  if (t->nodeIdentifier == DECLARATION_BLOCK)
    {
      do
	{
	  int type = getType(t);
	  TERNARY_TREE subT = t->first;
	  // install type in symbol table for each variable
	  do
	    {
	      symTab[subT->item]->type = type;
	    } while ((subT->first != NULL) && (subT = subT->first));

	} while ((t->third != NULL) && (t = t->third));
    }	
}

void PrintTree(TERNARY_TREE t, int nestLevel)
{
   if (t == NULL) return;
   int indent = nestLevel * INDENTOFFSET;
   nestLevel++;
   int i;
   for (i = 0; i < indent; ++i) printf(" ");
   printf("nodeIdentifier: %s ",NodeName[t->nodeIdentifier]);
   //printf("Item: ");
   PrintItem(t); printf("\n");
   PrintTree(t->first, nestLevel);
   PrintTree(t->second, nestLevel);
   PrintTree(t->third, nestLevel);
}

TERNARY_TREE create_node(int ival, int case_identifier, TERNARY_TREE p1,
			 TERNARY_TREE  p2, TERNARY_TREE  p3)
{
    TERNARY_TREE t;
    t = (TERNARY_TREE)malloc(sizeof(TREE_NODE));
    t->item = ival;
    t->nodeIdentifier = case_identifier;
    t->first = p1;
    t->second = p2;
    t->third = p3;
    return (t);
}

#include "lex.yy.c"
#include "splcodegen.c"
