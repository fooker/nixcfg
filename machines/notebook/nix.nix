{ lib, pkgs, path, nodes, config, ... }:

with lib;

let
  # All builders
  builders = filter
    (node: node.builder.enable)
    (mapAttrsToList (_: node: node.config) nodes);

in
{
  nix = {
    buildMachines = concatMap
      (builder: map
        (system: {
          inherit system;
          hostName = builder.dns.host.domain.toSimpleString;
          sshUser = "root";
          sshKey = config.sops.secrets."builder/sshKey".path;
          speedFactor = if system == builder.nixpkgs.localSystem.system then 2 else 1;
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

    settings = {
      trusted-users = lib.mkOptionDefault [ "fooker" ];
    };
  };

  sops.secrets."builder/sshKey" = {
    format = "binary";
    sopsFile = ./secrets/id_builder;
    group = "nixbld";
  };

  gather.parts."builder/sshKey" = {
    name = "id_builder.pub";
    command = ''
      ${pkgs.openssh}/bin/ssh-keygen -y -f "${config.sops.secrets."builder/sshKey".path}"
    '';
  };
}
