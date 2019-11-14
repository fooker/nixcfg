{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./default.nix
  ];

  config = mkIf (config.boot.type == "systemd") {
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
