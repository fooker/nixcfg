{ config, lib, pkgs, name, ... }:

with lib;
let
  hostId = toString (import (pkgs.runCommandLocal "hostid-${ name }" {} "echo ${ name } | sha512sum | head -c4 | od -A none -t x4 > $out"));
in {
  options.common.network = {
    enable = mkOption {
        type = types.bool;
        default = true;
    };
  };

  config = mkIf config.common.network.enable {
    networking = {
      inherit hostId;

      hostName = mkDefault name;

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
    systemd.services = mkIf config.systemd.network.enable {
      "systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";
      #"systemd-resolved".environment.SYSTEMD_LOG_LEVEL = "debug";
    };

    programs.mtr.enable = true;
  };
}