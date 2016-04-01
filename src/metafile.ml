open Opal

type author = {
  username : string;
  email : string
} [@@deriving yojson]

type constraints =
  | Not of constraints
  | And of constraints * constraints
  | Or of constraints * constraints
  | Eq of string
  | NEq of string
  | Less of string
  | Greater of string
  | LEq of string
  | GEq of string
  [@@deriving yojson]

let version_string = between (exactly '"') (exactly '"') (many (none_of ['"'])) => implode

let rec parse_constraint =
  eqc <|> neqc <|> lessc <|> greaterc <|> leqc <|> geqc <|> notc <|> andc <|> orc
and notc = exactly '!' >> parse_constraint
and andc = parse_constraint >>= fun c1 -> exactly '&' >> parse_constraint >>= fun c2 -> return (And (c1, c2))
and orc  = parse_constraint >>= fun c1 -> exactly '|' >> parse_constraint >>= fun c2 -> return (Or (c1, c2))
and eqc  = exactly '=' >> version_string => fun x -> Eq x
and neqc = exactly '!' >> exactly '=' >> version_string => fun x -> NEq x
and lessc = exactly '<' >> version_string => fun x -> Less x
and greaterc = exactly '>' >> version_string => fun x -> Greater x
and leqc = exactly '<' >> exactly '=' >> version_string => fun x -> LEq x
and geqc = exactly '>' >> exactly '=' >> version_string => fun x -> GEq x


type package = {
  package_name : string;
  constraints : constraints option
} [@@deriving yojson]

let parse_package =
  (* Which other characters can we not use? *)
  let package_string = many (none_of ['{'; '}'])
  and package_constraint = between (exactly '{') (exactly '}') parse_constraint in
  (package_string => implode) >>= fun name ->
  ((package_constraint => fun x -> Some x) <|> return None) >>= fun constr ->
  return {package_name = name; constraints = constr}

let package_of_string string =
  LazyStream.of_string string |> parse parse_package

type meta = {
  name : string;
  version : string;
  license : string;
  author : author;
  homepage : string option;
  synopsis : string;
  package_type : [`Exe | `Lib];
  dependencies : package list
} [@@deriving yojson]

let depend meta string =
  match package_of_string string with
  | Some pkg -> {meta with dependencies = pkg::meta.dependencies}
  | None -> meta

let save_meta ?(filename=".opamcreate") meta =
  meta_to_yojson meta |> Yojson.Safe.to_file filename

let load_meta ?(filename=".opamcreate") () =
  Yojson.Safe.from_file filename |> meta_of_yojson
