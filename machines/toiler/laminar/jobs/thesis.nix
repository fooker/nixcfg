{ lib, pkgs, ... }:

with lib;

let
  repo = "https://gogs.informatik.hs-fulda.de/fooker/thesis.git";

in {
  "thesis" = {
    environment = {
      PATH = makeBinPath (with pkgs; [ coreutils git nix ]);

      # Provide a fixed <nixpkgs> to pin latex version
      NIX_PATH = "nixpkgs=${ pkgs.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "21.05";
        sha256 = "1ckzhh24mgz6jd1xhfgx0i9mijk6xjqxwsshnvq789xsavrmsc36";
      } }";
    };

    run = ''
      # Fetch the source and switch to it
      git clone ${ repo } -b master .

      # Build the PDF
      nix-shell shell.nix --run "make"

      # Archive the output
      cp -v thesis.pdf $ARCHIVE/
    '';
  };
}