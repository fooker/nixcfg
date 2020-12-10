let
  sources = import ./nix/sources.nix;
  unstable = import sources.nixpkgs-unstable {};
  overlays = [
    (_: pkgs: {
      inherit (import sources.niv {}) niv;

      morph = (unstable.callPackage (sources.morph + "/nix-packaging") {}).overrideAttrs (_: {
        patches = [ ./patches/morph-evalConfig-machineName.patch ];
      });
    })
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
    drone
  ];
}

