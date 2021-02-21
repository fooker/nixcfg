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

  mkMachine = path:
    let
      /* Read the machine configuration from machine.nix in the machines directory
      */
      machine = import "${path}/machine.nix";

    in { config, lib, name, ... }: {
      _module.args = {
        inherit machine path;
      };

      deployment = {
        targetHost = machine.target.host;
        targetUser = machine.target.user;

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

  machines = name:
    with pkgs.lib;
    let
      # Path of a (potential) machine
      path = "${toString ./machines}/${concatStringsSep "/" name}";
    in
      # Machines must have a machine.nix file
      if (builtins.pathExists "${path}/machine.nix" )
      then {
        name = "${concatStringsSep "-" (name)}"; # Build the name of the machine
        value = mkMachine path; # Build the machine config
      }
      else flatten
        (mapAttrsToList
          (entry: type:
            # Filter for entries which are sub-directories and recurse into sub-directory while append sub-directory name to machine name
            if type == "directory"
              then machines (name ++ [entry]) 
              else [])
          (builtins.readDir path)); # Read entries in path

in
  {
    network = {
      inherit pkgs;
      evalConfig = name: (import "${findNixpkgs name}/nixos/lib/eval-config.nix");
    };
  } // (builtins.listToAttrs (machines []))
