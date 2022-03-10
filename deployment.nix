let
  sources = import ./nix/sources.nix;

  pkgs = import sources.nixpkgs { };

  mkMachine = path: id: { lib, config, ... }:
    with lib;

    let
      /* Read the machine configuration from machine.nix in the machines directory
      */
      machine = import "${path}/machine.nix";

      /* Generate tags for a machine path
      */
      genTags = path:
        if path != [ ]
        then (genTags (init path)) ++ [ (concatStringsSep "-" path) ]
        else [ ];

    in
    {
      _module.args = {
        inherit machine path id;
      };

      deployment = {
        targetHost = machine.target.host;
        targetUser = machine.target.user;

        tags = machine.tags
          ++ (genTags (init id));

        substituteOnDestination = true;
      };

      nixpkgs = {
        config = {
          allowUnfree = true;
        };

        overlays = [
          (_: _: {
            /* Make nixpkgs-unstable available as subtree
            */
            unstable = import sources.nixpkgs-unstable {
              config = config.nixpkgs.config;
              system = machine.system;
            };
          })
        ];

        localSystem.system = machine.system;
      };

      nix.distributedBuilds = true;

      imports = [
        ./modules
        ./shared
        path
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
        value = (mkMachine machine.path machine.id);
      })
      machines);

in
{
  network = {
    lib = pkgs.lib;
    evalConfig = name:
      let
        # Find the nixpkgs path for the machine with the given name
        path = sources."nixpkgs-${name}" or sources.nixpkgs;

        # Import the lib from the selected nixpkgs path and extend it with our own functions
        lib = import ./lib (import (path + "/lib"));

      in
      args: (import (path + "/nixos/lib/eval-config.nix")) (args // { inherit lib; });
  };
} // machines
