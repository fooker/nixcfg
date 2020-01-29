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
          machine = "${name}";
          machinePath = lib.path machine;
          machineConfig = lib.config machine; 
        in {
          _module.args = {
            inherit machine machineConfig sources;
          };

          deployment = {
            targetHost = machineConfig.target.host;
            targetUser = machineConfig.target.user;
          };

          nixpkgs.pkgs = import sources.nixpkgs {
            config = {};
            system = machineConfig.system;
          };
          nixpkgs.localSystem.system = machineConfig.system;

          nix.distributedBuilds = true;

          imports = [
            ./common.nix
            machinePath
          ];
        };
    in
      builtins.listToAttrs
        (builtins.map
          (name: { name = name; value = buildMachine name; })
          (builtins.attrNames (builtins.readDir ./machines))
        )
  )
