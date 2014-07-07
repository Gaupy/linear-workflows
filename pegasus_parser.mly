%{
(** Parser for specifications of DAGs of tasks for PEGASUS Dataflows *)
  open Def
%}

%token LHOOK RHOOK EOF
%token <string> STRING
%token <int> INT
%token <float> FL


%type<Def.spec> parse
%start parse

%%

parse:
 | task               { ($1::[],[]) }
 | task parse     {let (ts,dp) = $2 in ($1::ts,dp) }
 | edges           { ([],$1::[]) }
 | edges parse  { let (ts,dp) = $2 in (ts,$1::dp) }
 | EOF { ([],[])}

task:
| STRING INT LHOOK FL RHOOK { {id=$2;w=$4;c=1.;r=1.} }

edges:
 | STRING INT STRING INT { ($4,$2) }
