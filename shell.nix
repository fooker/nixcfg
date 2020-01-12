let
  pkgs = import ./nix;

in pkgs.mkShell {
  buildInputs = with pkgs; [
    bash
    git
    gnutar
    gzip
    morph
    niv
    nix
    openssh
  ];
}

