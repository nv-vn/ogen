# opam-create
A tool for creating new OCaml projects with OPAM, Oasis, and Merlin

## Usage

The basic usage is `opam create [-nopam] [-noasis] [project name]`.

The `-noasis` flag disables the `_oasis` generator and the `-nopam` flag disables generating OPAM packaging files.

```bash
$ opam create
Package name? [default: <current directory>] MyProject
Package version? [default: 1.0.0] 1.0
Please choose a license: [default: All Rights Reserved] GPL
Author name? [default: <git config user.name>]
Author email? [default: <git config user.email>]
Project homepage URL? https://github.com/<user>/<repo>
Project synopsis? <A short description of your project>
What does the package build? [Library/Executable] l
```
