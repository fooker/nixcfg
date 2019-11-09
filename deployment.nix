let
  lib = import ./lib.nix;
  pkgs = import (builtins.fetchTarball (with import ./nixpkgs.nix; {
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    })) {};
in
  {
    network = {
      inherit pkgs;
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
            inherit machine machineConfig;
          };

          deployment = {
            targetHost = machineConfig.target.host;
            targetUser = machineConfig.target.user;
          };

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
