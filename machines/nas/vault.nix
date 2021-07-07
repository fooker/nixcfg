{ lib, pkgs, utils, ... }:

with lib;
let
  disks = [
    "disk1"
    "disk2"
    "disk3"
    "disk4"
    "disk5"
    "disk6"
    "log"
    "cache"
  ];

in
{
  boot.supportedFilesystems = [ "zfs" ];

  systemd.services = listToAttrs
    (map
      (name: nameValuePair "cryptsetup@${ (utils.escapeSystemdPath "vault-${ name }") }" {
        unitConfig = {
          Description = "Cryptography Setup for %I";
          DefaultDependencies = false;
          Conflicts = [ "umount.target" ];
          IgnoreOnIsolate = true;
          Before = [ "zfs-import-vault.service" "unmount.target" ];
          RequiresMountsFor = [ "/etc/keys/vault.key" ];
          BindsTo = [ (utils.escapeSystemdPath "dev/disk/by-label/vault-${ name }-crypt.device") ];
          After = [ (utils.escapeSystemdPath "dev/disk/by-label/vault-${ name }-crypt.device") ];
        };

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          TimeoutSec = 0;
          KeyringMode = "shared";
          OOMScoreAdjust = 500;
          ExecStart = "${ pkgs.cryptsetup }/bin/cryptsetup luksOpen /dev/disk/by-label/vault-${ name }-crypt vault-${ name } --verbose --key-file /etc/keys/vault.key";
          ExecStop = "${ pkgs.cryptsetup }/bin/cryptsetup luksClose vault-${ name }";
        };

        wantedBy = [ "zfs-import.target" ];
      })
      disks);

  services.udev.extraRules = concatStringsSep "\n"
    (map
      (name: ''SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", ENV{DM_NAME}=="vault-${ name }", SYMLINK+="disk/vault/${ name }"'')
      disks);

  boot.zfs = {
    devNodes = "/dev/disk/vault";
    extraPools = [ "vault" ];
  };

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };
}
