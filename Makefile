all: nix/opam-selection.nix
	nix-build -A eagle

shell: nix/opam-selection.nix
	nix-shell

nix/opam-selection.nix: Makefile nix/default.nix default.nix Eagle.opam
	nix-shell -A resolve default.nix

make-deps-graph:
	dune-deps | tred | dot -Tpng > deps.png

exec:
	dune exec eagle