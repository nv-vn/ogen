{
  open Parsedep
  exception Eof
}

rule token = parse
  | [' ' '\t' '\n' '\r']
    { token lexbuf }
  | ['a'-'z' 'A'-'Z' '0'-'9' '-' '_' '.']+ as name
    { NAME name }
  | '['
    { string "" false lexbuf }
  | '{'
    { LBRACE }
  | '}'
    { RBRACE }
  | '!'
    { NOT }
  | '&'
    { AND }
  | '|'
    { OR }
  | '='
    { EQ }
  | '>'
    { GREATER }
  | '<'
    { LESS }
  | eof
    { EOF }

and string acc escaped = parse
  | '\\'
    { string acc true lexbuf }
  | ']'
    { if not escaped then VERSION acc
      else string (acc ^ "\"") escaped lexbuf }
  | _ as ch
    { if not escaped then string (acc ^ (String.make 1 ch)) escaped lexbuf
      else string (acc ^ "\\" ^ (String.make 1 ch)) escaped lexbuf }
