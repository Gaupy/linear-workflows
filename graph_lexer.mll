{
  open Graph_parser
}

rule token = parse
| [' ' '\t' '\n'] { token lexbuf }
| ['0'-'9']+ as lxm { INT (int_of_string lxm) }
| ['0'-'9']+"."['0'-'9']* as s { FL (float_of_string s) }
| "->"            { ARROW }
| '='            { EQUAL }
| '{'            { LBRACE }
| '}'            { RBRACE }
| ';'            { SEMICOLON }
| '['            { LHOOK}
| ']'            { RHOOK}
| '\"'            { QUOTE }
| ['a'-'z''A'-'Z']+ as lxm { STRING lxm }
| eof            { assert false }
