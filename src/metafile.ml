type author = {
  username : string;
  email : string
} [@@deriving yojson]

type meta = {
  name : string;
  version : string;
  license : string;
  author : author;
  homepage : string option;
  synopsis : string;
  package_type : [`Exe | `Lib]
} [@@deriving yojson]

let save_meta ?(filename=".opamcreate") meta =
  meta_to_yojson meta |> Yojson.Safe.to_file filename

let load_meta ?(filename=".opamcreate") () =
  Yojson.Safe.from_file filename |> meta_of_yojson
