open Metafile
open Batteries

let template : (string -> string -> string -> string -> string -> unit,
                unit BatInnerIO.output, unit) Printf.t = [%blob "../templates/.merlin"]

let fill_template ~filename ~sourcedir ~buildir ~packages ~extensions ~flags =
  File.with_file_out filename
    (fun handle ->
       Printf.fprintf handle template sourcedir buildir packages extensions flags)

let generic_fill filename {dependencies} =
  let packages = List.map (fun x -> x.package_name) dependencies |> String.concat "" in
  fill_template ~filename ~sourcedir:"src/" ~buildir:"_build/src/" ~packages ~extensions:"" ~flags:""
