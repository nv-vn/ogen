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

type package = {
  package_name : string;
  constraints : constraints option
} [@@deriving yojson]

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

let save_meta ?(filename=".opamcreate") meta =
  open_out filename |> fun handle -> begin
    meta_to_yojson meta |> Yojson.Safe.pretty_to_channel handle;
    close_out handle
  end

let load_meta ?(filename=".opamcreate") () =
  Yojson.Safe.from_file filename |> meta_of_yojson
