{ config, lib, pkgs, machine, ... }:

with lib;
{
  options.commons.network = {
    enable = mkOption {
        type = types.bool;
        default = true;
    };
  };

  config = mkIf config.commons.network.enable {
    networking = {
      hostName = machine;

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