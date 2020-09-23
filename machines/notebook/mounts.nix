{ pkgs, sources, ... }:

let
  secrets = import ./secrets.nix;
in {
  fileSystems."/mnt/vault" = {
    device = "nas.home.open-desk.net:/";
    fsType = "nfs4";
    options = ["x-systemd.automount" "noauto"];
  };
  
  fileSystems."/mnt/cantina" = {
    device = "//192.168.31.16/cantina";
    fsType = "cifs";
    options = ["x-systemd.automount" "noauto"
      "username=${secrets.mounts.cantina.password}"
      "password=${secrets.mounts.cantina.password}"
    ];
  };
}
