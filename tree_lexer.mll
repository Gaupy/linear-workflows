{
  open Tree_parser
}

rule token = parse
  | [' ' '\t'] { token lexbuf }
  | '%'         { comment lexbuf }
  | ['0'-'9']+ as lxm { INT (int_of_string lxm) }
  | '\n'             { NEWLINE }
  | eof  { EOF}

and comment = parse
  | '\n' { NEWLINE }
  | _    { comment lexbuf }
