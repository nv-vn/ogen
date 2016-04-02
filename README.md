# ogen
A tool for creating new OCaml projects with OPAM, Oasis, and Merlin

## Installation

If you have `opam` installed and are on OCaml version 4.02 or higher, you can simply run `opam install ogen`.

## Usage

### Creating a project

The basic usage is `ogen [-nopam] [-noasis] [project name]`.

The `-noasis` flag disables the `_oasis` generator and the `-nopam` flag disables generating OPAM packaging files.

```bash
$ ogen
Package name? [default: <current directory>] MyProject
Package version? [default: 1.0.0] 1.0
Please choose a license: [default: All Rights Reserved] GPL
Author name? [default: <git config user.name>]
Author email? [default: <git config user.email>]
Project homepage URL? https://github.com/<user>/<repo>
Project synopsis? <A short description of your project>
What does the package build? [Library/Executable] l
```

### Updating the project

To regenerate the files from the `.ogen` file, you can run `ogen -refresh`.

*WARNING: This will clear out changes to your current _oasis, opam, and .merlin files*

### Adding dependencies

If you want to add a new dependency, you can do so using the following syntax: `ogen -depend <dependency>`,
where `<dependency>` matches the following format:

```
name ::= any string

version ::= any string

constraint ::= "{" constraints "}"

op ::= "=" | "!=" | "<" | ">" | "<=" | ">="

constraints ::= op "[" version "]"
              | "!" constraints
              | constraints "&" constraints
              | constraints "|" constraints

dependency ::= name constraint?
```

Because of limitations of shells, you'll need to quote the dependency if you're using any constraints.

## Planned features

* Human-editable global config file?
  + Could be TOML, INI, JSON, YAML. Preferably not a custom format
  + Replace .opamcreate
  + Inject code into OASIS' Makefile to refresh?

* `ogen -tests` - Generate a test section in your `_oasis` file and create the directory
