open Batteries

let () =
  (* Skip either "opam-create" or "opam create" *)
  let current =
      if Sys.argv.(0) = "opam" && Sys.argv.(1) = "create" then 1
      else 0 in
  Arg.current := current;
  let usage = "opam create [-noasis] [-nopam] [name]" in
  let oasis = ref true
  and opam  = ref true
  and name  = ref None
  and mode  = ref `Gen in
  Arg.parse [
    "-noasis", Arg.Clear oasis, "Don't output OASIS file";
    "-nopam",  Arg.Clear opam,  "Don't output OPAM repo files";
    "-depend", Arg.Rest (fun s -> mode := `Depend s), "Add a dependency";
    "-refresh", Arg.Unit (fun _ -> mode := `Refresh), "Regenerate all files";
    "-main", Arg.String (fun s -> mode := `Main s), "Set the main module for compilation";
    "-modules", Arg.Rest (fun s -> mode := `Modules s), "Add modules to export";
    "-tests", Arg.Unit (fun _ -> mode := `Test), "Generate tests for the repository"
  ] (fun n -> name := Some n) usage;
  match !mode with
  | `Gen -> begin
      match UserInput.create !oasis !opam !name with
      | None -> ()
      | Some meta ->
        Merlin.generic_fill ".merlin" meta;
        if !oasis then Oasis.generic_fill "_oasis" meta;
        if !opam then Opam.generic_fill "opam" meta (* Maybe emit to sub-dir? *)
    end
  | `Refresh -> begin
      match Metafile.load_meta () with
      | `Ok meta ->
        Merlin.generic_fill ".merlin" meta;
        Oasis.generic_fill "_oasis" meta;
        Opam.generic_fill "opam" meta
      | `Error _ -> print_endline "Error: Generate a project before running `opam create -refresh`"
    end
  | `Depend dependency -> begin
      match Metafile.load_meta () with
      | `Ok meta ->
        let lexbuf = Lexing.from_string dependency in
        let dep = Parsedep.main Lexdep.token lexbuf in
        let meta' = Metafile.{meta with dependencies = dep::meta.dependencies} in
        Metafile.save_meta meta';
        Merlin.generic_fill ".merlin" meta';
        Oasis.generic_fill "_oasis" meta';
        Opam.generic_fill "opam" meta'
      | `Error _ -> print_endline "Error: Generate a project before running `opam create -refresh`"
    end
  | _ -> print_endline "Not yet implemented!"
