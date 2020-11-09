let
  sources = import ./nix/sources.nix;

  /* Find the nixpkgs path for the machine with the given name
  */
  nixpkgs = name:
    (sources."nixpkgs-${name}" or sources.nixpkgs);

  nixpkgs-unstable = sources.nixpkgs-unstable;
  nixpkgs-master = sources.nixpkgs-master;

  mkMachine = name: { config, lib, ... }:
    let
      /* The path of the machine
      */
      path = "${toString ./.}/machines/${name}";

      /* Read the machine configuration from machine.nix in the machines directory
      */
      machine = import "${path}/machine.nix";

    in {
      _module.args = {
        inherit machine path sources;
      };

      deployment = {
        targetHost = machine.target.host;
        targetUser = machine.target.user;

        substituteOnDestination = true;
      };

      nixpkgs.pkgs = import (nixpkgs name) {
        config = {
          allowUnfree = true;

          packageOverrides = pkgs: {
            /* Make nixpkgs-unstable available as subtree
            */
            unstable = import nixpkgs-unstable {
              config = config.nixpkgs.config;
              system = machine.system;
            };

            /* Make nixpkgs-master available as subtree
            */
            master = import nixpkgs-master {
              config = config.nixpkgs.config;
              system = machine.system;
            };
          };

          overlays = [
            (import ./lib)
          ];
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
in
  {
    network = {
      pkgs = import sources.nixpkgs {
        config = {};
      };

      evalConfig = name: (import "${nixpkgs name}/nixos/lib/eval-config.nix");
    };
  } // (builtins.listToAttrs (builtins.map # Build machine config for each machine in machines directory
      (name: { name = name; value = mkMachine name; })
      (builtins.attrNames (builtins.readDir ./machines))))
