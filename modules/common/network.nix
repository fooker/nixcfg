{ config, lib, pkgs, name, ... }:

with lib;
{
  options.common.network = {
    enable = mkOption {
        type = types.bool;
        default = true;
    };
  };

  config = mkIf config.common.network.enable {
    networking = {
      hostName = name;

      domain = "open-desk.net";
      search = [ "open-desk.net" ];

      dhcpcd.enable = false;

      firewall = {
        enable = true;
        allowPing = true;
        checkReversePath = false;
      };
    };

    # Enable debugging for systemd-networkd
    systemd.services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";

    programs.mtr.enable = true;
  };
}