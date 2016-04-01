# opam-create
A tool for creating new OCaml projects with OPAM, Oasis, and Merlin

## Usage

### Creating a project

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

### Updating the project

To regenerate the files from the `.opamcreate` file, you can run `opam create -refresh`.

### Adding dependencies

If you want to add a new dependency, you can do so using the following syntax: `opam create -depend <dependency>`,
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

* `opam create -main <main file>` - Create the main file and add it to the `_oasis` file
* `opam create -modules <modules>` - Create the specified modules and add them to the `_oasis` file
* `opam create -tests` - Generate a test section in your `_oasis` file and create the directory
