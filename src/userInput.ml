open Batteries
open Batteries.Option
open Batteries.Option.Infix

let prompt_or_empty prompt =
  LNoise.linenoise prompt >>= function "" -> None | s -> Some s

let prompt_default prompt default_option =
  let prompt' = prompt ^ " [default: " ^ default_option ^ "] " in
  let input = LNoise.linenoise prompt' >>= function "" -> None | s -> Some s in
  default default_option input

let try_getval ini section value =
  ini >>= fun ini' ->
  try Some (ini'#getval section value)
  with _ -> None

let create oasis opam name =
  let prompt_and_create () =
    let name = match name with
      | None ->
        let cwd = Sys.getcwd () in
        let default_dir = String.rsplit cwd ~by:"/" |> snd in
        prompt_default "Package name?" default_dir
      | Some name -> name
    and version =
      let default_ver = "1.0.0" in
      prompt_default "Package version?" default_ver
    and license = prompt_default "Please choose a license:" "PROP"
    and gitconfig =
      try
        let home = Sys.getenv "HOME" in
        Some (new Inifiles.inifile (home ^ "/.gitconfig"))
      with _ -> None in
    let author_name =
      let default_name = try_getval gitconfig "user" "name" in
      prompt_default "Author name?" (default "" default_name)
    and author_email =
      let default_email = try_getval gitconfig "user" "email" in
      prompt_default "Author email?" (default "" default_email)
    and homepage = prompt_or_empty "Project homepage URL? "
    and synopsis = default "" (LNoise.linenoise "Project synopsis? ") (* Don't print "[default: ...]"! *)
    and package_type =
      let get_option = function
        | "l" | "L" | "lib" | "Lib" | "library" | "Library" -> Some `Lib
        | "e" | "E" | "exe" | "Exe" | "executable" | "Executable" -> Some `Exe
        | s -> None in
      let rec get_input () =
        let input = LNoise.linenoise "What does the package build? [Library/Executable] " in
        match input >>= get_option with
        | Some option -> option
        | None -> print_endline "Please enter valid input!"; get_input () in
      get_input () in
    let meta = Metafile.{
        name; version; license; homepage; synopsis; package_type; dependencies = [];
        author = {username = author_name; email = author_email}
      } in Metafile.save_meta meta;
    meta in
  if Sys.file_exists ".opamcreate" then begin
    print_string "Some files have already been generated. This will overwrite the current repository. \
                  Are you sure you want to continue? [Y/n] ";
    flush stdout;
    match input_char stdin with
    | 'N' | 'n' -> None
    | _ -> Some (prompt_and_create ())
  end else Some (prompt_and_create ())
