let
  sources = import ./nix/sources.nix;

  buildMachine = name: { config, ... }: 
    let
      /* The path of the machine
      */
      path = ./. + "/machines/${name}";

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

      nixpkgs.pkgs = import sources.nixpkgs {
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
      nixConfig = {
        "builders" = "ssh://nixos-builder i686-linux,x86_64-linux,aarch64-linux,armv6l-linux,armv7l-linux 8";
        "builders-use-substitutes" = "true";
      };
    };
  } // (builtins.listToAttrs (builtins.map # Build machine config for each machine in machines directory
      (name: { name = name; value = buildMachine name; })
      (builtins.attrNames (builtins.readDir ./machines))))
