%{
  open Metafile
%}

%token EOF
%token LBRACE RBRACE
%token NOT AND OR EQ GREATER LESS
%token <string> NAME
%token <string> VERSION

%start main
%type <Metafile.package> main

%%

main:
  | NAME EOF
    { {package_name = $1; constraints = None} }
  | NAME LBRACE constraints RBRACE EOF
    { {package_name = $1; constraints = Some $3} }
;

constraints:
  | NOT constraints
    { Not $2 }
  | constraints AND constraints
    { And ($1, $3) }
  | constraints OR constraints
    { Or ($1, $3) }
  | EQ VERSION
    { Eq $2 }
  | NOT EQ VERSION
    { NEq $3 }
  | LESS VERSION
    { Less $2 }
  | GREATER VERSION
    { Greater $2 }
  | LESS EQ VERSION
    { LEq $3 }
  | GREATER EQ VERSION
    { GEq $3 }
;
