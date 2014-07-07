{
  open Pegasus_parser
}

rule token = parse
| [' ' '\t' '\n'] { token lexbuf }
| ['0'-'9']+"."['0'-'9']* as lxm { FL (float_of_string lxm) }
| ['0'-'9']+ as lxm { INT (int_of_string lxm) }
| '['            { LHOOK}
| ']'            { RHOOK}
| ['a'-'z''A'-'Z']+ as lxm { STRING lxm }
| eof {EOF}
