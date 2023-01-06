{ nixpkgs
, ipam
, ...
}@inputs:

let
  deploymentPkgs = import nixpkgs {
    localSystem.system = "x86_64-linux";
  };

  mkMachine = machine: { lib, ... }:
    with lib;

    let
      # Generate tags for a machine path
      genTags = path:
        if path != [ ]
        then (genTags (init path)) ++ [ (concatStringsSep "-" path) ]
        else [ ];

    in
    {
      _module.args = {
        inherit machine;
        inherit (machine) path id;
      };

      deployment = {
        targetHost = machine.target.host;
        targetUser = machine.target.user;

        tags = machine.tags
          ++ (genTags (init machine.id));
      } // (machine.deployment or { });

      nix.distributedBuilds = true;

      nixpkgs.overlays = [
        # Make nixpkgs-unstable available as subtree
        (_: _: {
          unstable = import inputs.nixpkgs-unstable {
            localSystem.system = machine.system;
            config = {
              allowUnfree = true;
            };
          };
        })

        # Patch lego to add some detailed logging
        (_: super: {
          lego = super.lego.overrideAttrs (attrs: rec {
            patches = attrs.patches or [ ] ++ [
              ./patches/lego-logging.patch
            ];
          });
        })
      ];

      imports = [
        ./modules
        ./shared
        machine.path
      ];

      system.stateVersion = machine.stateVersion;
    };

  machines =
    let
      machines = (deploymentPkgs.callPackage ./machines.nix { }).machines;
    in
    builtins.listToAttrs (map
      (machine: {
        name = machine.name;
        value = {
          # Find the nixpkgs path for the machine with the given name
          nixpkgs = import (inputs."nixpkgs-${machine.name}" or nixpkgs) {
            localSystem.system = machine.system;
            config = {
              allowUnfree = true;
            };
          };

          # Build the machines
          system = mkMachine machine;
        };
      })
      machines);

in
(builtins.mapAttrs
  (_: machine: machine.system)
  machines)
  // {
  meta = {
    nixpkgs = deploymentPkgs;

    nodeNixpkgs = builtins.mapAttrs
      (_: machine: machine.nixpkgs)
      machines;

    nodeSpecialArgs = builtins.mapAttrs
      (_: machine: {
        # Inject the lib extensions
        lib = (machine.nixpkgs.lib.extend (import ./lib)).extend (import "${ipam}/lib");

        # All available inputs
        inputs = (removeAttrs inputs [ "self" ]);
      })
      machines;
  };
}
