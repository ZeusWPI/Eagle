(lang dune 3.2)

(name Eagle)

(generate_opam_files true)

(source
 (github zeuswpi/Eagle))

(authors "Maxime Bloch")

(maintainers "Maxime Bloch")

; (license MIT) TODO

(documentation https://url/to/documentation)

(package
 (name Eagle)
 ; (synopsis "A short synopsis")
 ; (description "A longer description")
 (depends ocaml dune lwt cohttp-lwt-unix cohttp-lwt-unix-ssl cohttp-async async-ssl yojson)
 ; (tags
 ;  (topics "to describe" your project))
 )

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
