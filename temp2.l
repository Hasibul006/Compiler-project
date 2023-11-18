%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<math.h>
	#include<string.h>
	#include   "temp2.tab.h"
	void yyerror(char *s);
	int lineno = 0;
	int varindex(char *var);
	extern int yylex();
	extern int yyparse();
	extern FILE *yyout;
%}


VAR      [a-zA-Z_][a-z0-9A-Z_]*
EXPO      [Ee][-+]?[0-9]+


%%

[0-9]*		{yylval.para  = atoi(yytext);return NUMBER;}

\"[^"\n]*["\n]	 {return STRING; }
									
"int"  	return INT;
"char"	 return CHAR;
"float" 	 return FLOAT;
"double"	return DOUBLE;
"bool"       return BOOL;
"void"  return VOID;
";"           return EOL;
"main function"				{	printf("Main function starts from here\n");return CODE_START;}
"("         return FB_OPEN; 
")"         return FB_CLOSE;
"["        { return '['; }
"]"        { return ']'; }
"{"        { return '{'; }
"}"        { return '}'; } 

"!"        return FACTORIAL;

									
"="    return ASSIGN;
">="    return GE;
">"     return '>';
"<"     return '<';
"=="     return '=';
"<="    return LE;
"!="    return NE;
","	    return ',';
"+"      return '+';
"-"      return '-';
"*"      return '*'; 
"/"      return '/';
":"		return ':';
">>"   return CIN;
"<<"  return COUT;
 
"%"      return '%'; 
"while_loop" return WHILE;
"for"   return FOR;
"++"       return INC;
"--"		return DEC;
"if"    return IF;
"elseif"   return ELSEIF;
"else"  return ELSE;
"then"  return THEN;
"power"     return POWER;
"write" return PRINT;
"read"  return INPUT;
"exit"  return EXIT;
"br"   return BREAK;

   
[a-zA-Z_][a-z0-9A-Z_]* {
		yylval.var = strdup(yytext);
		return VARIABLE;
}

[ \t\n]*
 

"#include"     { return INCLUDE; } 
{VAR}".h"      { return HEADER;}
%%

int main()
{
	printf("RUN SUCCESSFULLY : \n");
	freopen("in.txt","r",stdin);
	freopen("out.txt","w",stdout);
	yyparse();
	return 0;
} 
int yywrap() {
    return 1;
}

void yyerror(char *s) {
    fprintf(stdout, "line %d: %s\n", lineno, s);
}
