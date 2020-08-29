let
  sources = import ./nix/sources.nix;

  /* Find the nixpkgs path for the machine with the given name
  */
  nixpkgsPath = name:
    (sources."nixpkgs-${name}" or sources.nixpkgs);

  mkMachine = name: { config, ... }: 
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
      };

      nixpkgs.pkgs = import (nixpkgsPath name) {
        config = {
          allowUnfree = true;

          packageOverrides = pkgs: {
            unstable = import sources.nixpkgs-unstable {
              config = config.nixpkgs.config;
            };
          };
        };

        system = machine.system;
      };
      
      nixpkgs.localSystem.system = machine.system;

      nix.distributedBuilds = true;

      imports = [
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

      evalConfig = name: (import "${nixpkgsPath name}/nixos/lib/eval-config.nix");
    };
  } // (builtins.listToAttrs (builtins.map # Build machine config for each machine in machines directory
      (name: { name = name; value = mkMachine name; })
      (builtins.attrNames (builtins.readDir ./machines))))
