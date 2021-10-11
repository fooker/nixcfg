{ pkgs, lib, path, nodes, ... }:

with lib;

let
  # All builders
  builders = filter
    (node: node.builder.enable)
    (mapAttrsToList (_: node: node.config) nodes);

  # Unique set of systems over all nodes
  systems = unique (map
    (node: node.config.nixpkgs.localSystem.system)
    (attrValues nodes));

in
{
  nix = {
    buildCores = 8;

    buildMachines = concatMap
      (builder: map
        (system: {
          inherit system;
          hostName = builder.dns.host.domain.toSimpleString;
          sshUser = "root";
          sshKey = "/var/lib/id_builder";
          speedFactor = if system == builder.nixpkgs.localSystem.system then 8 else 4;
          maxJobs = 8;
          supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
          mandatoryFeatures = [ ];
        })
        systems)
      builders;

    distributedBuilds = true;

    extraOptions = ''
      builders-use-substitutes = true
    '';

    trustedUsers = lib.mkOptionDefault [ "fooker" ];
  };

  deployment.secrets = {
    "builder-sshkey" = rec {
      source = "${path}/secrets/id_builder";
      destination = "/var/lib/id_builder";
      owner.user = "root";
      owner.group = "nixbld";
      action = [
        ''
          ${pkgs.openssh}/bin/ssh-keygen -y -f ${destination} > ${destination}.pub
        ''
      ];
    };
  };
}
