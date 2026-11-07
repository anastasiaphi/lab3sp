%{
#include <stdio.h>
#include <stdlib.h>


typedef struct Node {
    char op;              
    int value;            
    struct Node *left;    
    struct Node *right;   
} Node;


Node *make_num(int value) {
    Node *n = malloc(sizeof(Node));
    n->op = 'n';
    n->value = value;
    n->left = NULL;
    n->right = NULL;
    return n;
}


Node *make_op(char op, Node *left, Node *right) {
    Node *n = malloc(sizeof(Node));
    n->op = op;
    n->value = 0;
    n->left = left;
    n->right = right;
    return n;
}

void print_tree(Node *n, int depth) {
    for (int i = 0; i < depth; i++) printf("    ");
    if (n->op == 'n') printf("%d\n", n->value);
    else              printf("%c\n", n->op);
    if (n->left)  print_tree(n->left,  depth + 1);
    if (n->right) print_tree(n->right, depth + 1);
}

/* значення дерева */
int eval(Node *n) {
    if (n->op == 'n') return n->value;   

    int a = eval(n->left);               
    int b = eval(n->right);             

    if (n->op == '+') return a + b;
    if (n->op == '-') return a - b;
    if (n->op == '*') return a * b;
    if (n->op == '/') {
        if (b == 0) { printf("Помилка: ділення на нуль\n"); return 0; }
        return a / b;
    }
    return 0;
}
FILE *out; 
void gen(Node *n) {
    if (n->op == 'n') {                 
        fprintf(out, "%d", n->value);
        return;
    }
    fprintf(out, "(");                  
    gen(n->left);
    if (n->op == '/') fprintf(out, " // ");
    else              fprintf(out, " %c ", n->op);
    gen(n->right);
    fprintf(out, ")");
}
int yylex(void);
void yyerror(const char *s) { printf("Помилка: %s\n", s); }
%}

%union {
    int num;
    struct Node *node;
}

%token <num> NUM
%type <node> expr

%left '+' '-'
%left '*' '/'

%%

lines
    : %empty
    | lines '\n'
        | lines expr '\n'      {
                             printf("Дерево:\n");
                             print_tree($2, 0);
                             printf("= %d\n", eval($2));
                             fprintf(out, "print(");
                             gen($2);
                             fprintf(out, ")\n");
                           }
    ;

expr
    : expr '+' expr        { $$ = make_op('+', $1, $3); }
    | expr '-' expr        { $$ = make_op('-', $1, $3); }
    | expr '*' expr        { $$ = make_op('*', $1, $3); }
    | expr '/' expr        { $$ = make_op('/', $1, $3); }
    | '(' expr ')'         { $$ = $2; }
    | NUM                  { $$ = make_num($1); }
    ;

%%

int main() {
    out = fopen("out.py", "w");
    yyparse();
    fclose(out);
    return 0;
}