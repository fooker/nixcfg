{ nixpkgs
, ipam
, dns
, gather
, sops
, private
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
      imports = [
        ./modules
        ./shared

        machine.path

        sops.nixosModules.sops
        dns.nixosModules.default
        gather.nixosModules.default
      ];

      _module.args = {
        inherit machine;
        inherit (machine) path id;

        private = import private;
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

        # Let builders fetch sources directly instead of uploading
        (self: super: (super.prefer-remote-fetch self super))
      ];

      sops = {
        defaultSopsFile = lib.mkForce (machine.path + "/secrets.yaml");
        defaultSopsFormat = "yaml";

        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };

      gather = {
        target = name: "${machine.relPath}/gathered/${name}";
        root = ./.;
      };

      system.stateVersion = machine.stateVersion;
    };

  machines =
    let
      inherit (deploymentPkgs.callPackage ./machines.nix { }) machines;
    in
    builtins.listToAttrs (map
      (machine: {
        inherit (machine) name;
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
        lib = machine.nixpkgs.lib.foldl
          (lib: lib.extend)
          machine.nixpkgs.lib
          [
            (import ./lib)
            ipam.lib
            dns.lib
          ];

        # All available inputs
        inputs = removeAttrs inputs [ "self" ];
      })
      machines;
  };
}
