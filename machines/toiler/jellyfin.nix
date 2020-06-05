{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  services.jellyfin = {
    enable = true;
  };

  fileSystems."/mnt/media" = {
    device = "nas.home.open-desk.net:/media";
    fsType = "nfs4";
    options = ["x-systemd.automount" "noauto"];
  };

  networking.firewall.interfaces = {
    "priv" = {
      allowedTCPPorts = [ 8096 ];
    };
  };

  backup.paths = [
    "/var/lib/jellyfin"
  ];
}