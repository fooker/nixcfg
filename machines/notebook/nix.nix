{ pkgs, sources, lib, path, ... }:

{
  nix = {
    buildCores = 8;

    buildMachines = [ {
      hostName = "builder";
      systems = [ "i686-linux" "x86_64-linux" "aarch64-linux" "armv6l-linux" "armv7l-linux"];
      speedFactor = 8;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }] ;

    distributedBuilds = true;

    extraOptions = ''
      builders-use-substitutes = true
    '';

    trustedUsers = lib.mkOptionDefault [ "fooker" ];
  };

  programs.ssh.extraConfig = ''
    Host brueckenkopf
      IdentitiesOnly yes
      User root
      HostName brueckenkopf.dev.open-desk.net
      IdentityFile /var/lib/id_builder
    Host builder
      IdentitiesOnly yes
      User root
      HostName 192.168.42.2
      ProxyJump brueckenkopf
      IdentityFile /var/lib/id_builder
  '';

  deployment.secrets = {
    "builder-sshkey" = rec {
      source = "${path}/secrets/id_builder";
      destination = "/var/lib/id_builder";
      owner.user = "root";
      owner.group = "nixbld";
      action = [ ''
        ${pkgs.openssh}/bin/ssh-keygen -y -f ${destination} > ${destination}.pub
      '' ];
    };
  };
}
