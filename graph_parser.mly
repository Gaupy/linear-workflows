%{
(** Parser for specifications of DAGs of tasks *)
  open Def
%}

%token LBRACE RBRACE LHOOK RHOOK SEMICOLON ARROW EQUAL QUOTE
%token <string> STRING
%token <int> INT
%token<float> FL


%type<Def.spec> parse
%start parse

%%

parse:
| STRING STRING LBRACE specs RBRACE { $5 }

specs:
 | task SEMICOLON specs { let (ts,dp) = $3 in ($1::ts,dp) }
 | edges { [],$1 }

task:
| INT LHOOK STRING EQUAL QUOTE FL QUOTE RHOOK { {w=$6;c=1.;r=1.} }

edges:
 | EOF { [] }
 | INT ARROW INT SEMICOLON edges { ($1,$3)::$5 }
 | INT ARROW INT SEMICOLON { ($1,$3)::[] }

edges:
| { E.empty }
| INT ARROW INT SEMICOLON edges { ($1,$3)::$5 }
