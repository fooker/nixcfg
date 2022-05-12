{ nixpkgs
, ipam
, ...
}@inputs:

let
  pkgs = import nixpkgs { };

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
      };

      nix.distributedBuilds = true;

      imports = [
        ./modules
        ./shared
        machine.path
      ];

      system.stateVersion = machine.stateVersion;
    };

  machines =
    let
      machines = (pkgs.callPackage ./machines.nix { }).machines;
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

            overlays = [
              # Make nixpkgs-unstable available as subtree
              (_: _: {
                unstable = import inputs.nixpkgs-unstable {
                  localSystem.system = machine.system;
                  config = {
                    allowUnfree = true;
                  };
                };
              })
            ];
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
    nixpkgs = pkgs;

    nodeNixpkgs = builtins.mapAttrs
      (_: machine: machine.nixpkgs)
      machines;

    specialArgs = {
      # Inject the lib extensions
      lib = (pkgs.lib.extend (import ./lib)).extend (import "${ipam}/lib");

      # All available inputs
      inputs = (removeAttrs inputs [ "self" ]);
    };
  };
}
