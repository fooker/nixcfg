{ config, lib, pkgs, ... }:

with lib;
{
  config = mkIf (config.boot.type == "systemd") {
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
