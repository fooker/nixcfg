let
  sources = import ./nix/sources.nix;
  overlays = [
    (_: pkgs: { inherit (import sources.niv {}) niv; })
    (_: pkgs: { morph = pkgs.callPackage (sources.morph + "/nix-packaging") {}; })
  ];
  pkgs = import sources.nixpkgs {
    inherit overlays;
    config = {};
  };

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

