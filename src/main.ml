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
    "-modules", Arg.Rest (fun s -> match !mode with `Modules t -> mode := `Modules (s ^ " " ^ t) | _ -> mode := `Modules s), "Add modules to export";
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
      | `Error _ -> print_endline "Error: Generate a project before running `opam create -depend`"
    end
  | `Main main -> begin
      match Metafile.load_meta () with
      | `Ok ({Metafile.package_type = `Exe _} as meta) ->
        let meta' = Metafile.{meta with package_type = `Exe main} in
        Metafile.save_meta meta';
        Merlin.generic_fill ".merlin" meta';
        Oasis.generic_fill "_oasis" meta';
        Opam.generic_fill "opam" meta';
        if Sys.file_exists ("src/" ^ main) then ()
        else if Sys.file_exists "src/" then
          File.with_file_out ("src/" ^ main)
            (fun handle -> Printf.fprintf handle "let () = ()")
        else begin
          Unix.mkdir "src/" 0o744;
          File.with_file_out ("src/" ^ main)
            (fun handle -> Printf.fprintf handle "let () = ()")
        end
      | `Ok {Metafile.package_type = `Lib _} -> print_endline "Error: Only executables can contain a main file"
      | `Error _ -> print_endline "Error: Generate a project before running `opam create -main`"
    end
  | `Modules modules -> begin
      match Metafile.load_meta () with
      | `Ok ({Metafile.package_type = `Lib old_modules} as meta) ->
        let modules' = String.nsplit ~by:" " modules in
        let meta' = Metafile.{meta with package_type = `Lib (List.append old_modules modules' |> List.unique)} in
        Metafile.save_meta meta';
        Merlin.generic_fill ".merlin" meta';
        Oasis.generic_fill "_oasis" meta';
        Opam.generic_fill "opam" meta';
        if not (Sys.file_exists "src/") then
          Unix.mkdir "src/" 0o744
        else ();
        let create_module module_ =
          let file = String.uncapitalize module_ ^ ".ml" in
          if Sys.file_exists ("src/" ^ file) then ()
          else File.with_file_out ("src/" ^ file)
              (fun handle -> Printf.fprintf handle "let () = ()") in
        List.iter create_module modules'
      | `Ok {Metafile.package_type = `Exe _} -> print_endline "Error: Only libraries can contain modules"
      | `Error _ -> print_endline "Error: Generate a project before running `opam create -modules`"
    end
  | _ -> print_endline "Not yet implemented!"
