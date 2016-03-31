open Metafile
open Batteries

let template : (string -> string -> string -> string -> string -> string -> string -> string -> string -> string -> unit,
                unit BatInnerIO.output, unit) Printf.t = [%blob "../templates/opam"]

let fill_template ~filename ~author_name ~author_email ~homepage ~license ~name ~dependencies =
  let bug_reports = homepage ^ "/issues" (* Specific to Github/Gitlab/Bitbucket *)
  and dev_repo = homepage ^ ".git" in (* Specific to Git in general *)
  File.with_file_out filename
    (fun handle ->
       Printf.fprintf handle template author_name author_email author_name author_email homepage bug_reports license dev_repo name dependencies)

let generic_fill filename {author = {username; email}; homepage; license; name; dependencies} =
  let expand_package {package_name; constraints} =
    let rec format_constraint = function
      | Not c -> "!" ^ format_constraint c
      | And (a, b) -> format_constraint a ^ " & " ^ format_constraint b
      | Or (a, b) -> format_constraint a ^ " | " ^ format_constraint b
      | Eq v -> "= \"" ^ v ^ "\""
      | NEq v -> "!= \"" ^ v ^ "\""
      | Less v -> "< \"" ^ v ^ "\""
      | Greater v -> "> \"" ^ v ^ "\""
      | LEq v -> "<= \"" ^ v ^ "\""
      | GEq v -> ">= \"" ^ v ^ "\"" in
    let string_of_constraint c = " {" ^ format_constraint c ^ "}" in
    (* Tabulate 2 spaces for all of these *)
    match Option.map string_of_constraint constraints with
    | Some c -> "  \"" ^ package_name ^ "\"" ^ c
    | None -> "  \"" ^ package_name ^ "\"" in
  let packages = List.map expand_package dependencies |> String.concat "\n"
  and homepage = match homepage with Some h -> h | None -> "" in
  fill_template ~filename ~author_name:username ~author_email:email ~homepage ~license ~name ~dependencies:packages
