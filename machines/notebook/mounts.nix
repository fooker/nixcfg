{ nodes, ... }:

let
  secrets = import ./secrets.nix;
in
{
  fileSystems."/mnt/vault" = {
    device = "//nas.dev.home.open-desk.net/vault";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "username=share"
      "password=${nodes."nas".config.users.users."share".password}"
    ];
  };

  fileSystems."/mnt/cantina" = {
    device = "//10.32.30.95/cantina";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "username=${secrets.mounts.cantina.username}"
      "password=${secrets.mounts.cantina.password}"
    ];
  };
}
