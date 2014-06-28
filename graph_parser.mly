%{
(** Parser for specifications of DAGs of tasks *)
  open Def
%}

%token LBRACE RBRACE LHOOK RHOOK SEMICOLON ARROW EQUAL QUOTE
%token <string> STRING
%token <int> INT
%token <float> FL


%type<Def.spec> parse
%start parse

%%

parse:
| STRING STRING LBRACE specs RBRACE { $4 }

specs:
 | task SEMICOLON specs { let (ts,dp) = $3 in ($1::ts,dp) }
 | task SEMICOLON { ([$1],[]) }
 | edges SEMICOLON specs { let (ts,dp) = $3 in (ts,$1::dp) }
 | edges SEMICOLON { ([],[$1]) }

task:
| INT LHOOK STRING EQUAL QUOTE FL QUOTE RHOOK { {id=1;w=$6;c=1.;r=1.} }

edges:
 | INT ARROW INT { ($1,$3) }
