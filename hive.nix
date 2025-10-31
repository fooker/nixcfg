{
  self,
  inputs,
  lib,
  ...
}:

with lib;

let
  #deploymentPkgs = import nixpkgs {
  #  localSystem.system = "x86_64-linux";
  #};

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

        inputs.disko.nixosModules.disko
        inputs.sops.nixosModules.sops
        inputs.dns.nixosModules.default
        inputs.nftables.nixosModules.default
        inputs.gather.nixosModules.default
      ];

      _module.args = {
        inherit machine;
        inherit (machine) path id;

        private = import inputs.private;
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

        inputs.ucware-client.overlays.ucware-client
      ];

      sops = {
        defaultSopsFile = machine.path + "/secrets.yaml";
        defaultSopsFormat = "yaml";

        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };

      gather = {
        target = name: "${machine.relPath}/gathered/${name}";
        root = ./.;
      };

      system.stateVersion = machine.stateVersion;
    };

in
{
  flake.colmenaHive = inputs.colmena.lib.makeHive self.colmena;

  flake.colmena = {
    meta = rec {
      nixpkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";

      # Find the right nixpkgs for each node and initialize it with the machines system
      nodeNixpkgs = mapAttrs
        (name: machine: let
          nixpkgs = (inputs."nixpkgs-${name}" or inputs.nixpkgs);
        in nixpkgs.legacyPackages.${machine.system})
        self.lib.machines;

      nodeSpecialArgs = mapAttrs
        (name: _: {
          # Inject the lib extensions
          lib = foldl'
            (lib: lib.extend)
            nodeNixpkgs.${name}.lib
            [
              inputs.ipam.lib
              inputs.dns.lib
              inputs.nftables.lib
            ];

          # All available inputs
          inputs = removeAttrs inputs [ "self" ];
        })
        self.lib.machines;
    };
  } // (mapAttrs
    (_: machine: mkMachine machine)
    self.lib.machines);

  flake.nixosConfigurations = self.colmenaHive.nodes;
}
