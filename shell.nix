let
  sources = import ./nix/sources.nix;
  unstable = import sources.nixpkgs-unstable {};
  overlays = [
    (_: pkgs: {
      inherit (import sources.niv {}) niv;

      morph = (unstable.callPackage (sources.morph + "/nix-packaging") {});
    })
  ];
  pkgs = import sources.nixpkgs {
    inherit overlays;
    config = {};
  };

in pkgs.mkShell {
  buildInputs = with pkgs; [
    bash
    gitAndTools.git
    gitAndTools.transcrypt
    gnutar
    gzip
    morph
    niv
    nix
    openssh
    drone-cli
  ];
}

