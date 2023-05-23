{ config, lib, pkgs, path, utils, ... }:

with lib;

{
  config = mkIf config.hive.enable {
    systemd.mounts = [{
      type = "btrfs";

      what = "/dev/disk/by-label/data";
      where = "/data";

      options = "noatime,discard";

      bindsTo = [ "systemd-cryptsetup@data.service" ];

      wantedBy = [ "local-fs.target" ];
    }];

    systemd.services."systemd-cryptsetup@data" = {
      unitConfig = {
        DefaultDependencies = false;
        IgnoreOnIsolate = true;
        After = [
          "cryptsetup-pre.target"
          "systemd-udevd-kernel.socket"
          (utils.escapeSystemdPath "dev/disk/by-label/data-crypt.device")
        ];
        Before = [
          "blockdev@dev-mapper-data.target"
          "cryptsetup.target"
          "umount.target"
        ];
        Wants = [
          "blockdev@dev-mapper-data.target"
        ];
        Conflicts = [
          "umount.target"
        ];
        RequiresMountsFor = [
          config.sops.secrets."luks/data".path
        ];
        BindsTo = [
          (utils.escapeSystemdPath "dev/disk/by-label/data-crypt.device")
        ];
      };

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        TimeoutSec = 0;
        KeyringMode = "shared";
        OOMScoreAdjust = 500;
        ExecStart = "${pkgs.systemd}/lib/systemd/systemd-cryptsetup attach 'data' '/dev/disk/by-label/data-crypt' '${config.sops.secrets."luks/data".path}' ''";
        ExecStop = "${pkgs.systemd}/lib/systemd/systemd-cryptsetup detach 'data'";
      };
    };

    sops.secrets."luks/data" = {
      format = "binary";
      sopsFile = /${path}/secrets/luks-data.key;
    };
  };
}
