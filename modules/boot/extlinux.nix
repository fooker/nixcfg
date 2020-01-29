{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./default.nix
  ];

  config = mkIf (config.boot.type == "extlinux") {
    boot.loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };
}
