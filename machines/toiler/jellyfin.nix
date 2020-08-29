{ pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  nixpkgs.overlays = [ (self: super: {
    jellyfin = pkgs.unstable.jellyfin;
  }) ];

  services.jellyfin = {
    enable = true;
  };

  fileSystems."/mnt/media" = {
    device = "nas.home.open-desk.net:/media";
    fsType = "nfs4";
    options = ["x-systemd.automount" "noauto"];
  };

  reverse-proxy = {
    enable = true;
    hosts = {
      "jellyfin" = {
        domains = [ "jellyfin.home.open-desk.net" ];
        target = "http://[::1]:8096";
      };
    };
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
