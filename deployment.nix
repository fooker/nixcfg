let
  lib = import ./lib.nix;
  sources = import ./nix/sources.nix;
in
  {
    network = {
      pkgs = import sources.nixpkgs {
        config = {};
      };
      nixConfig = {
        "builders" = "ssh://nixos-builder i686-linux,x86_64-linux,aarch64-linux,armv6l-linux,armv7l-linux 8";
        "builders-use-substitutes" = "true";
      };
    };
  } // (
    let
      buildMachine = name: { config, pkgs, ...} : 
        let
          path = lib.path name;
          machine = lib.config name; 
        in {
          _module.args = {
            inherit machine path sources;
          };

          deployment = {
            targetHost = machine.target.host;
            targetUser = machine.target.user;
          };

          nixpkgs.pkgs = import sources.nixpkgs {
            config = {};
            system = machine.system;
          };
          nixpkgs.localSystem.system = machine.system;

          nix.distributedBuilds = true;

          imports = [
            ./common.nix
            path
          ];
        };
    in
      builtins.listToAttrs
        (builtins.map
          (name: { name = name; value = buildMachine name; })
          (builtins.attrNames (builtins.readDir ./machines))
        )
  )
