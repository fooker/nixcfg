{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./default.nix
  ];

  config = mkIf (config.boot.type == "grub") {
    boot.loader = {
      grub.enable = true;
      grub.version = 2;
      grub.device = "/dev/sda";
    };
  };
}
