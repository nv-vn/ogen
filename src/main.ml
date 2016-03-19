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
  and name  = ref None in
  Arg.parse [
    "noasis", Arg.Clear oasis, "Don't output OASIS file";
    "nopam",  Arg.Clear opam,  "Don't output OPAM repo files"
  ] (fun n -> name := Some n) usage;
  UserInput.create !oasis !opam !name
