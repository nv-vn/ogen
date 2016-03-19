open Batteries
open Batteries.Option
open Batteries.Option.Infix

let prompt_default prompt default_option =
  let prompt' = prompt ^ " [default: " ^ default_option ^ "] " in
  let input = LNoise.linenoise prompt' >>= function "" -> None | s -> Some s in
  default default_option input

let try_getval ini section value =
  ini >>= fun ini' ->
  try Some (ini'#getval section value)
  with _ -> None

let create oasis opam name =
  let name = match name with
    | None ->
      let cwd = Sys.getcwd () in
      let default_dir = String.rsplit cwd ~by:"/" |> snd in
      prompt_default "Package name?" default_dir
    | Some name -> name
  and version =
    let default_ver = "1.0.0" in
    prompt_default "Package version?" default_ver
  and license = prompt_default "Please choose a license:" "All Rights Reserved"
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
  and homepage = LNoise.linenoise "Project homepage URL? "
  and synopsis = default "" (LNoise.linenoise "Project synopsis? ")
  and package_type =
    let get_option = function
      | "l" | "L" | "lib" | "Lib" | "library" | "Library" -> Some `Lib
      | "e" | "E" | "exe" | "Exe" | "executable" | "Executable" -> Some `Exe
      | s -> None in
    let rec get_input () =
      let input = LNoise.linenoise "What does the package build? [Library/Executable]" in
      match input >>= get_option with
      | Some option -> option
      | None -> print_endline "Please enter valid input!"; get_input () in
    get_input () in
  if oasis then
    Oasis.gen_oasis ~name ~version ~synopsis ~author_name ~author_email ~license ~package_type;
  if opam then
    Opam.gen_opam ~name ~version ~synopsis ~author_name ~author_email ~license ~homepage;
  Merlin.gen_merlin ()

