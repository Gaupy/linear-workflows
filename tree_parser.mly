%{
(** Parser for specifications of Trees of tasks *)
  open Def
%}

%token NEWLINE EOF
%token <int> INT


%type<Def.spec_tree> parse
%start parse

%%

parse:
| INT NEWLINE parse { $3 }
| line parse  { let a, (b1,b2), c = $1 and d, e, f = $2 in ({id=f ; w = a.w ; c=1.;r=1.}::d, (b1, f)::e, f+1) }
| NEWLINE parse {$2}
| EOF {([],[],0)}

line:
| INT INT INT { ({id=0 ; w = float_of_int ($2 + $3) ; c=1.;r=1.} , ($1,0), 1) }

