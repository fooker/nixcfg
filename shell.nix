let
  sources = import ./nix/sources.nix;

  overlays = [
    (self: _: {
      inherit (import sources.niv { }) niv;

      morph = (self.callPackage sources.morph { }).overrideAttrs (attrs: {
        patches = attrs.patches or [ ] ++ [
          ./patches/morph-evalConfig-machineName.patch
        ];
      });

      nix-pre-commit-hooks = import sources.nix-pre-commit-hooks;
    })
  ];

  pkgs = import sources.nixpkgs {
    inherit overlays;
    config = { };
  };

  nix-pre-commit-hooks = pkgs.nix-pre-commit-hooks.run {
    src = ./.;
    hooks = {
      nixpkgs-fmt = {
        enable = true;
        excludes = [ "^nix/" ];
      };

      nix-linter = {
        enable = true;
        excludes = [ "^nix/" ];
      };

      shellcheck.enable = true;
    };
    settings = {
      nix-linter.checks = [ "No-UnfortunateArgName" ];
    };
  };

in
pkgs.mkShell {
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
    nixpkgs-fmt
    nix-linter
    shellcheck
  ];

  inherit (nix-pre-commit-hooks) shellHook;
}

