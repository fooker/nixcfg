{ pkgs, lib, config, ... }:

{
  fileSystems."/mnt/work/hlb" = {
    device = "//fileserver1.rz.hs-fulda.de/DATA2/HLB";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "credentials=${config.sops.secrets."mounts/work/credentials".path}"
      "uid=fooker"
      "gid=users"
      "nodfs"
    ];
  };

  fileSystems."/mnt/work/home" = {
    device = "//fileserver1.rz.hs-fulda.de/HOME2/HLB/fdhlb212";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "credentials=${config.sops.secrets."mounts/work/credentials".path}"
      "uid=fooker"
      "gid=users"
      "nodfs"
    ];
  };

  fileSystems."/mnt/work/prog" = {
    device = "//fileserver2.rz.hs-fulda.de/PROG";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "credentials=${config.sops.secrets."mounts/work/credentials".path}"
      "uid=fooker"
      "gid=users"
      "nodfs"
    ];
  };

  system.nssModules = [ pkgs.xhosts ];
  system.nssDatabases.hosts = lib.mkOrder 100 [ "xhosts" ];

  sops.secrets."mounts/work/credentials" = { };
}

