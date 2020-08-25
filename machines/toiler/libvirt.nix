{ pkgs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
  };

  fileSystems."/mnt/machines" = {
    device = "nas.home.open-desk.net:/machines";
    fsType = "nfs4";
    options = ["x-systemd.automount" "noauto"];
  };
}
