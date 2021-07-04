let
  sources = import ./nix/sources.nix;

  pkgs = import sources.nixpkgs {
    config = {};
  };

  /* Find the nixpkgs path for the machine with the given name
  */
  findNixpkgs = name:
    (sources."nixpkgs-${name}" or sources.nixpkgs);

  nixpkgs-unstable = sources.nixpkgs-unstable;
  nixpkgs-master = sources.nixpkgs-master;

  mkMachine = path: id:
    let
      /* Read the machine configuration from machine.nix in the machines directory
      */
      machine = import "${path}/machine.nix";

    in { config, lib, name, ... }: {
      _module.args = {
        inherit machine path id;
      };

      deployment = {
        targetHost = machine.target.host;
        targetUser = machine.target.user;

        inherit (machine) tags;

        substituteOnDestination = true;
      };

      nixpkgs.pkgs = import (findNixpkgs name) {
        config = {
          allowUnfree = true;

          packageOverrides = pkgs: {
            /* Make nixpkgs-unstable available as subtree
            */
            unstable = import nixpkgs-unstable {
              config = config.nixpkgs.config;
              system = machine.system;
            };
          };
        };

        system = machine.system;
      };
      
      nixpkgs.localSystem.system = machine.system;

      nix.distributedBuilds = true;

      imports = [
        ./ext
        ./tools
        ./modules
        ./shared
        path
      ];

      system.stateVersion = machine.stateVersion;
    };

  machines = let
    machines = (pkgs.callPackage ./machines.nix {}).machines;
  in
    builtins.listToAttrs (map
      (machine: {
        name = machine.name;
        value = (mkMachine machine.path machine.id);
      })
      machines);

in
  {
    network = {
      inherit pkgs;
      evalConfig = name: (import "${findNixpkgs name}/nixos/lib/eval-config.nix");
    };
  } // machines
