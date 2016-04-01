open Metafile
open Batteries

let template : (string -> string -> string -> string -> string -> string -> string -> string -> string -> string -> string -> unit,
               unit BatInnerIO.output, unit) Printf.t = [%blob "../templates/_oasis"]

let fill_template ~filename ~name ~version ~synopsis ~author_name ~author_email ~license ~package_type ~sourcedir ~dependencies =
  let build_type, files = match package_type with
    | `Exe main -> ("Executable", "MainIs: " ^ main)
    | `Lib modules -> ("Library", "Modules: " ^ String.concat ", " modules) in
  File.with_file_out filename
    (fun handle ->
       Printf.fprintf handle template name version synopsis author_name author_email license build_type name sourcedir files dependencies)

let generic_fill filename {name; version; synopsis; author; license; package_type; dependencies} =
  let packages = List.map (fun x -> x.package_name) dependencies |> String.concat " " in
  fill_template ~filename ~name ~version ~synopsis ~author_name:author.username ~author_email:author.email ~license ~package_type
                ~sourcedir:"src/" ~dependencies:packages
