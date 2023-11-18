%{
    #include <stdio.h>
    #include <stdlib.h>
    #include<math.h>
    #include <string.h>	
    int yyerror(char *s);

    char var_name[1000][1000];
    int int_values[1000];
    int var_count=1;
    int data_type[1000];
    char string_values[1000][1000];
    float float_values[1000];
    int datatype;
    int condition_match;

    //int=1 float=2 char=3 

    //check the variable if it is declared before
    int isDeclared(char *v){
        int i;
        for(i=1;i<var_count;i++){
            if(strcmp(var_name[i],v)==0)return 1;
        }
        return 0;
    }


    //stores the names of the variables
    int store_var(char *v){
        if(isDeclared(v)==1)return 0;
        strcpy(var_name[var_count],v);
        int_values[var_count]=0;
        data_type[var_count]=datatype;
        var_count++;
        return 1;
    }


    //calculate expression
     int assign_value(char *s,int value)
     {
        if(isDeclared(s) == 0)
            return 0;
        int var_num=-1;
        for(int i=1; i<var_count; i++)
        {
            if(strcmp(var_name[i],s) == 0)
            {
                var_num=i;
                break;
            }
        }
        int_values[var_num]=value;
        return 1;
    }


    //get the value of the variable
    int getValue(char *v)
    {
        int num=-1;
        for(int i=1; i<var_count; i++)
        {
            if(strcmp(var_name[i],v) == 0)
            {
                num=i;
                break;
            }
        }
        return int_values[num];
    }
 
%}


%union  {
	float floatt;
    int num;
	char *var;
	char *str;
	int para;
    int valu;
};


%token <num> NUMBER
%token <var> VARIABLE
%token <str> STRING
%token <para> parameter
%type<num>expression
%type<str>id
%token<str>HEADER
%type<valu>EOL
%type<valu>statement
%type<valu>var_assignment
%type<str>include
%token INT FLOAT DOUBLE CHAR BOOL CODE_START INC DEC EOL FB_OPEN FB_CLOSE FACTORIAL POWER VOID EXIT PI WHILE FOR 
%token IF ELSEIF ELSE THEN PRINT INPUT SWITCH CASE DEFAULT ASSIGN LOG10 LN EXP SQRT FLOOR CEIL ABS SIN ASIN COS ACOS TAN ATAN BREAK INCLUDE FUNC 
%token CIN COUT 

%nonassoc IFX
%nonassoc ELSEIF
%nonassoc ELSE

%left GE LE '=' NE '>' '<'
%left '+' '-'
%left '*' '/' '%'
%left AND OR XOR
%left NOT

%%

program:
	include CODE_START '{' lines '}'	{printf("\n Program executed successfully\n");
                                        for(int i=1;i<var_count;i++)printf("%s = %d \n",var_name[i],int_values[i]);}
	|
	;
	
include:
	INCLUDE '[' HEADER ']' {printf("header found\n");}
	|
	;
	

lines :
    |
	|statement lines
	; 


statement:
		  EOL
		| declaration 
        | var_assignment EOL
		| expression EOL {$$=$1;}
		| print_any
        | take_input
        | for_loop
	    | WHILE FB_OPEN VARIABLE LE NUMBER ':' NUMBER FB_CLOSE '{' '}'	{printf("this is a while loop");}	
	    | WHILE FB_OPEN NUMBER FB_CLOSE '{' '}'	{printf("this is a while loop");}	
	    | if_statements	{condition_match=0;}	
	    ;

var_assignment:
               VARIABLE ASSIGN expression  {
                  if(assign_value($1,$3)==0){
                    $$=0;
                    printf("The %s variable is not declared\n",$1);
                  }else{
                    $$=$3;
                    printf("assignment: %s = %d\n",$1,$3);
                  }
               }

for_loop: 
       |FOR FB_OPEN var_assignment ':' VARIABLE '>' expression ':' NUMBER ':' '-' FB_CLOSE '{' statement '}' {
           printf("loop: %d %d %d\n",$3, $7, $9);
           for(int i=$3;i>$7;i=i-$9){
            printf("The loop is executed for %dth time\n",i);
           }
         }
       |FOR FB_OPEN var_assignment ':' VARIABLE '<' expression ':' NUMBER ':' '+' FB_CLOSE '{' statement '}' {
           printf("loop: %d %d %d\n",$3, $7, $9);
           for(int i=$3;i<$7;i=i+$9){
            printf("The loop is executed for %dth time\n",i);
           }
         }


take_input: 
        INPUT FB_OPEN VARIABLE FB_CLOSE  {
        if(isDeclared($3)==0){
            printf("The variable %s is not declared\n",$3);
        }else{
            printf("The input of %s is taken\n",$3);
        }
    }
                   

print_any: 
         |PRINT FB_OPEN VARIABLE FB_CLOSE EOL  {
            if(isDeclared($3)==0){
                printf("%s is not declared\n",$3);
            }else{
                printf("%s is printed\n",$3);
            }
         }
        

declaration :
	datatype id EOL
	;

datatype:
	  INT		{datatype=1;}
	| FLOAT		{datatype=2;}
	| CHAR		{datatype=3;}
	;


id:
	id ',' VARIABLE	{} {
        if(isDeclared($3)==1){
            printf("%s variable is declared before\n",$3);
        }
        else{
            store_var($3);
            printf("%s variable is declared successfully\n",$3);
        }
    }
	| VARIABLE	{} {
        if(isDeclared($1)==1){
            printf("%s variable is declared before\n",$1);
        }
        else{
            store_var($1);
            printf("%s variable is declared successfully\n",$1);
        }
    }
	| id ASSIGN expression	{
         if(assign_value($1,$3)==0){
            $$=0;
            printf("%s is not declared\n",$1);
         }else{
            $$=$3;
         }
    }
	;

		
if_statements:
            if_statement els_statement
			;

if_statement: 
			IF FB_OPEN expression FB_CLOSE THEN '{' statement '}'  {
                printf("inside if condition\n");
                if($3){
                    condition_match=1;
                    printf("%d The conditon is true\n",$3);
                }else{
                    printf("%d The conditon is not true\n",$3);
                }
            }
			;

els_statement:  
			| elif_statement
			| elif_statement last_else
			| last_else
		    ;

last_else: 
		| ELSE '{' statement '}' {
            if(condition_match){
                printf("this is ignored as another condtion is already checked true\n");
            }else{
                condition_match=1;
                printf("this condidion is default true\n",$3);
            }
        }
		;


elif_statement:
			elif_statement last_elif 
			| last_elif 
			;

last_elif:
		ELSEIF FB_OPEN expression FB_CLOSE THEN '{' statement '}'	{
            if(condition_match){
                printf("this condition %d is ignored as another condtion is already checked true\n",$3);
            }else{
                if($3){
                  condition_match=1;
                  printf("%d is condition is true\n",$3);
                }else{
                    printf("%d The conditon is not true\n",$3);
                }
                
            }
        }
		;


expression:	
        NUMBER	{$$=$1;}
        |VARIABLE {
            if(isDeclared($1)==0){
                printf("%s is not declard\n",$1);
            }else{
                $$=getValue($1);
            }
        }
        |expression '+' expression{
            $$=$1+$3;
            printf("sum: %d + %d = %d\n",$1,$3,$$);
        }
        |expression '-' expression{
            $$=$1-$3;
            printf("subtraction: %d - %d = %d\n",$1,$3,$$);
        }
        |expression '*' expression{
            $$=$1*$3;
            printf("Multiplication: %d * %d = %d\n",$1,$3,$$);
        }
        |expression '/' expression{
            $$=$1/$3;
            printf("Division: %d / %d = %d\n",$1,$3,$$);
        }
        |expression '%' expression	{
            int a=$1;
            int b=$3;
            int x=a%b;
            printf("Modulus: %d mod %d = %d\n",a,b,x);
        }
        |expression '>' expression	{
            $$=$1>$3;
            printf("greater then: %d > %d = %d\n",$1,$3,$$);
        }
        |VARIABLE INC	{
            int x;
            if(isDeclared($1)==0){
                printf("%s is not declard\n",$1);
            }else{
                x=getValue($1);
            }
            if(assign_value($1,x+1)==0){
                $$=0;
               printf("%s is not declared\n",$1);
            }else{
                $$=x+1;
              printf("increment: %s++ = %d\n",$1,x+1);
           }
        }
        |VARIABLE DEC	{
            int x;
            if(isDeclared($1)==0){
                printf("%s is not declard\n",$1);
            }else{
                x=getValue($1);
            }
            if(assign_value($1,x-1)==0){
                $$=0;
               printf("%s is not declared\n",$1);
            }else{
              $$=x-1;
              printf("decrement: %s-- = %d\n",$1,x-1);
           }
        }
        |expression '<' expression	{
            $$=$1<$3;
            printf("less then: %d < %d = %d\n",$1,$3,$$);
        }
        |expression '=' expression	{
            $$=$1==$3;
            printf("equal: %d == %d = %d\n",$1,$3,$$);
        }
        |expression NE expression	{
            $$=$1!=$3;
            printf("not equal: %d != %d = %d\n",$1,$3,$$);
        }

        |expression LE expression	{
            $$=$1<=$3;
            printf("less then equal: %d <= %d = %d\n",$1,$3,$$);
        }
        |expression GE expression	{
            $$=$1>=$3;
            printf("greater then equal: %d >= %d = %d\n",$1,$3,$$);
        }
        


%%



       
