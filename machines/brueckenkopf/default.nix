{ config, ... }:

{
  imports = [
    ./hardware.nix
    ./network.nix
    ./peering.nix
    ./mosh.nix
    ./weechat.nix
    ./monitoring
  ];

  server.enable = true;

  dns.host.interface = "ext";

  fileSystems."/mnt/cantina" = {
    device = "//192.168.31.16/cantina";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "credentials=${config.sops.secrets."mounts/cantina/credentials".path}"
    ];
  };

  sops.secrets."mounts/cantina/credentials" = { };
}
