#include <stdio.h>

const char CKeywordNullifier[] = "VAR";

void printIdentifier(int id)
{
  printf("%s%s", CKeywordNullifier, symTab[id]->identifier);
}

void printIndent(int indentLevel)
{
  int i;
  for (i = 0; i < indentLevel; ++i)
    printf("  ");
}

void printFormatString(TERNARY_TREE t)
{
  do
    {
      TERNARY_TREE value = t->first;
      // identifiers
      if (value->item != EXPRESSION && value->item != NOTHING)
	{
	  switch (symTab[value->item]->type)
	    {
	    case TYPE_CHARACTER:
	      printf("%%c");
	      break;
	    case TYPE_INTEGER:
	      printf("%%d");
	      break;
	    case TYPE_REAL:
	      printf("%%f");
	      break;
	    }
	}
      // constants
      else if (value->item == NOTHING)
	{
	  TERNARY_TREE constant = value->first;
	  if (constant->first == NULL) // char constant
	    printf("%%c");
	  else
	    {
	      switch (constant->first->nodeIdentifier)
		{
		case REAL_CONSTANT:
		case MINUS_REAL_CONSTANT:
		  printf("%%f");
		  break;
		case INTEGER_CONSTANT:
		case MINUS_INTEGER_CONSTANT:
		  printf("%%d");
		  break;
		}
	    }
	}
      // expressions - NOTE: this only checks the type on the left most side.
      else
	printFormatString(value->first->first);
      
    }  while ((t->second != NULL) && (t = t->second));
}

void SplToC(TERNARY_TREE t, int indentLevel)
{
  if (t == NULL) return;
  switch (t->nodeIdentifier)
    {
    case PROGRAM:
      printf("#include <stdio.h>\n");
      printf("int main()\n{\n");
      SplToC(t->first, indentLevel);
      printf("}\n");
      break;

    case BLOCK:
      SplToC(t->first, indentLevel+1);
      if (t->second != NULL)
	{
	  printf("\n");
	  SplToC(t->second, indentLevel+1);
	}
      break;

    case DECLARATION_BLOCK:
      printIndent(indentLevel);
      SplToC(t->second, indentLevel); printf(" ");
      SplToC(t->first, indentLevel);
      printf(";\n");
      if (t->third != NULL) SplToC(t->third, indentLevel);
      break;

    case IDENTIFIER_LIST:
      printIdentifier(t->item);
      if (t->first != NULL)
	{
	  printf(", ");
	  SplToC(t->first, indentLevel);
	}
      break;

    case TYPE_RULE:
      switch (t->item)
	{
	case TYPE_CHARACTER:
	  printf("char");
	  break;
	case TYPE_INTEGER:
	  printf("int");
	  break;
	case TYPE_REAL:
	  printf("float");
	  break;
	}
      break;

    case STATEMENT_LIST:
      SplToC(t->first, indentLevel);
      printf("\n");
      if (t->second != NULL) SplToC(t->second, indentLevel);
      break;

    case STATEMENT:
      SplToC(t->first, indentLevel);
      break;

    case ASSIGNMENT_STATEMENT:
      printIndent(indentLevel);
      printIdentifier(t->item); printf(" = ");
      SplToC(t->first, indentLevel);
      printf(";");
      break;

    case IF_STATEMENT:
      printIndent(indentLevel);
      printf("if (");
      SplToC(t->first, indentLevel);
      printf(")\n");
      printIndent(indentLevel); printf("{\n");
      SplToC(t->second, indentLevel+1);
      printIndent(indentLevel); printf("}");
      if (t->third != NULL)
	{
	  printf("\n");
	  printIndent(indentLevel); printf("else\n");
	  printIndent(indentLevel); printf("{\n");
	  SplToC(t->third, indentLevel+1);
	  printIndent(indentLevel); printf("}");
	}
      break;

    case DO_STATEMENT:
      printIndent(indentLevel); printf("do\n"); printIndent(indentLevel); printf("{\n");
      SplToC(t->first, indentLevel+1);
      printIndent(indentLevel); printf("} ");
      printf("while ("); SplToC(t->second, indentLevel); printf(");");
      break;

    case WHILE_STATEMENT:
      printIndent(indentLevel); printf("while ("); SplToC(t->first, indentLevel); printf(")\n");
      printIndent(indentLevel); printf("{\n"); SplToC(t->second, indentLevel+1);
      printIndent(indentLevel); printf("}");
      break;

    case FOR_STATEMENT:
      printIndent(indentLevel);
      printf("for ("); printIdentifier(t->item); printf(" = "); SplToC(t->first, indentLevel); printf("; ");
      printIdentifier(t->item); printf(" > "); SplToC(t->third->first, indentLevel); printf(" ? ");
      printIdentifier(t->item); printf(" > "); SplToC(t->third->first, indentLevel);
      printf(" : "); printIdentifier(t->item); printf(" < "); SplToC(t->third->first, indentLevel); printf("; ");
      printIdentifier(t->item); printf(" += "); SplToC(t->second, indentLevel); printf(")\n");

      printIndent(indentLevel); printf("{\n");
      SplToC(t->third->second, indentLevel+1);
      printIndent(indentLevel); printf("}");
      break;

    case WRITE_STATEMENT:
      printIndent(indentLevel);
      if (t->item == NEWLINE)
	printf("printf(\"\\n\")");
      else
	{
	  printf("printf(\"");
	  printFormatString(t->first); printf("\", ");
	  SplToC(t->first, indentLevel);
	  printf(")");
	}
      printf(";");
      break;

    case READ_STATEMENT:
      printIndent(indentLevel);
      printf("scanf(\"");
      switch (symTab[t->item]->type)
	    {
	    case TYPE_CHARACTER:
	      printf(" %%c");
	      break;
	    case TYPE_INTEGER:
	      printf("%%d");
	      break;
	    case TYPE_REAL:
	      printf("%%f");
	      break;
	    }
      printf("\", &");
      printIdentifier(t->item);
      printf(");");
      break;

    case OUTPUT_LIST:
      do
	{
	  SplToC(t->first, indentLevel);
	  if (t->second != NULL)
	    printf(", ");
	} while ((t->second != NULL) && (t = t->second));
      break;

    case CONDITION:
      if (t->item == NOT)
	printf("!(");
      SplToC(t->first, indentLevel);
      if (t->item == NOTHING)
	{
	  SplToC(t->second, indentLevel);
	  SplToC(t->third, indentLevel);
	}
      else
	printf(")");
      break;

    case CONDITIONAL:
      SplToC(t->first, indentLevel);
      if (t->second != NULL)
	{
	  if (t->item == AND)
	    printf(" && ");
	  else
	    printf(" || ");
	  SplToC(t->second, indentLevel);
	}
      break;

    case COMPARATOR:
      switch (t->item)
	{
	case EQUAL:
	  printf(" == ");
	  break;
	case NOT_EQUAL:
	  printf(" != ");
	  break;
	case LESS_THAN:
	  printf(" < ");
	  break;
	case GREATER_THAN:
	  printf(" > ");
	  break;
	case LESS_THAN_EQUAL:
	  printf(" <= ");
	  break;
	case GREATER_THAN_EQUAL:
	  printf(" >= ");
	  break;
	default:
	  fprintf(stderr, "%s%d", "Unknown t->item for COMPARATOR: ",
		  t->item);
	}
      break;

    case EXPRESSION:
      SplToC(t->first, indentLevel);
      if (t->second != NULL)
	{
	  if (t->item == PLUS)
	    printf(" + ");
	  else
	    printf(" - ");
	  SplToC(t->second, indentLevel);
	}
      break;

    case TERM:
      SplToC(t->first, indentLevel);
      if (t->second != NULL)
	{
	  if (t->item == MULTIPLY)
	    printf(" * ");
	  else
	    printf(" / ");
	  SplToC(t->second, indentLevel);
	}
      break;

    case VALUE:
      if (t->first != NULL)
	{
	  if (t->item == EXPRESSION)
	    {
	      printf("("); SplToC(t->first, indentLevel); printf(")");
	    }
	  else
	    SplToC(t->first, indentLevel);
	}
      else
	printIdentifier(t->item);
      break;

    case CONSTANT:
      if (t->first != NULL)
	SplToC(t->first, indentLevel);
      else
	printf("%s", symTab[t->item]->identifier);
      break;

    case REAL_CONSTANT:
    case MINUS_REAL_CONSTANT:
      printf("%s%s", t->nodeIdentifier == MINUS_REAL_CONSTANT ? "-" : "",
	     symTab[t->item]->identifier);
      break;

    case INTEGER_CONSTANT:
    case MINUS_INTEGER_CONSTANT:
      printf("%s%s", t->nodeIdentifier == MINUS_INTEGER_CONSTANT ? "-" : "",
	     symTab[t->item]->identifier);
      break;

    default:
      fprintf(stderr, "%s%d", "Unknown nodeIdentifier: ",
	      t->nodeIdentifier);
      break;
    }
}
