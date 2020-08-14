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
    git
    gnutar
    gzip
    (morph.overrideAttrs (_: {
        patches = [ ./patches/morph-evalConfig-machineName.patch ];
      }))
    niv
    nix
    openssh
  ];
}

