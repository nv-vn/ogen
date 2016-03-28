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
    "noasis", Arg.Clear oasis, "Don't output OASIS file";
    "nopam",  Arg.Clear opam,  "Don't output OPAM repo files";
    "depend", Arg.Rest (fun s -> mode := `Depend s), "Add a dependency";
    "refresh", Arg.Unit (fun _ -> mode := `Refresh), "Regenerate all files";
    "main", Arg.String (fun s -> mode := `Main s), "Set the main module for compilation";
    "modules", Arg.Rest (fun s -> mode := `Modules s), "Add modules to export";
    "tests", Arg.Unit (fun _ -> mode := `Test), "Generate tests for the repository"
  ] (fun n -> name := Some n) usage;
  match !mode with
  | `Gen -> begin
      match UserInput.create !oasis !opam !name with
      | None -> ()
      | Some meta -> Merlin.generic_fill ".merlin" meta
    end
  | _ -> print_endline "Not yet implemented!"
