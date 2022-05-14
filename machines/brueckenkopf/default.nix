let
  secrets = import ./secrets.nix;
in
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

  backup.passphrase = secrets.backup.passphrase;

  dns.host.interface = "ext";

  fileSystems."/mnt/cantina" = {
    device = "//192.168.31.16/cantina";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "username=${secrets.mounts.cantina.username}"
      "password=${secrets.mounts.cantina.password}"
    ];
  };
}
