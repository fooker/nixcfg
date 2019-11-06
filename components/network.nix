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

  programs.mtr.enable = true;
}