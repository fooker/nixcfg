{ config, lib, pkgs, machine, ... }:

{
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
}