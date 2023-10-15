{ lib, ... }:

with lib;
{
  imports = [
    ./grub.nix
    ./systemd.nix
  ];

  options.boot = {
    preset = mkOption {
      type = types.enum [ "grub" "systemd" "none" ];
      default = "systemd";
    };
  };

  config = {
    boot.tmp.useTmpfs = true;
  };
}
