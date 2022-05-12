{ lib, path, nodes, config, ... }:

with lib;

let
  # All builders
  builders = filter
    (node: node.builder.enable)
    (mapAttrsToList (_: node: node.config) nodes);

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
          sshKey = config.deployment.keys."builder-sshkey".path;
          speedFactor = if system == builder.nixpkgs.localSystem.system then 8 else 4;
          maxJobs = 8;
          supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
          mandatoryFeatures = [ ];
        })
        builder.builder.systems)
      builders;

    distributedBuilds = true;

    extraOptions = ''
      builders-use-substitutes = true
    '';

    trustedUsers = lib.mkOptionDefault [ "fooker" ];
  };

  deployment.keys = {
    "builder-sshkey" = rec {
      keyFile = "${path}/secrets/id_builder";
      destDir = "/etc/secrets";
      user = "root";
      group = "nixbld";
    };
  };
}
