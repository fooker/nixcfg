{ pkgs, sources, ... }:

{
  fileSystems."/mnt/vault" = {
    device = "nas.home.open-desk.net:/";
    fsType = "nfs4";
    options = ["x-systemd.automount" "noauto"];
  };
}
