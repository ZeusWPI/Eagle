# paramaterised derivation with dependencies injected (callPackage style)
{ pkgs, stdenv, opam2nix }:
let
	args = {
		inherit (pkgs.ocaml-ng.ocamlPackages_4_08) ocaml;
		selection = ./opam-selection.nix;
		src = ../.;
	};
	opam-selection = opam2nix.build args;

	# We have two dev dependencies, of slightly different kinds:
	#
	# `utop` is declared as an optional dependency in `Eagle.opam`,
	# which means it'll be used only if it's already available. By
	# adding it to `resolve` arguments, we ensure it's available.
	#
	# `ocamlformat` is not mentioned at all in `hello.opam`.
	# So we add it to `resolve` arguments, as above.
	# But our `Eagle` package doesn't reference it, because it
	# wasn't listed as a dependency. So we also override the
	# resulting nix derivation to add it to `buildInputs`.
	resolve = opam2nix.resolve args [
		"Eagle.opam" "utop" "ocamlformat=0.22.4"
	];

	# NOTE: If you only want `ocamlformat` to be available inside a nix shell
	# (and not `nix-build`), you should override the `Eagle` derivation
	# in shell.nix instead of here.
	eagle = opam-selection.Eagle.overrideAttrs (super: {
		buildInputs = (super.buildInputs or []) ++ [opam-selection.ocamlformat];
	});
in
{
	inherit eagle;
	inherit resolve;
}