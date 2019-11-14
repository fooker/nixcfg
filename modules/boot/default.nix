{ config, lib, pkgs, machineConfig, ... }:

with lib;
{
  imports = [
    ./grub.nix
    ./systemd.nix
  ];

  options.boot = {
    type = mkOption {
        type = types.enum [ "grub" "systemd" ];
        default = "systemd";
    };
  };

  config = {
    boot.tmpOnTmpfs = true;
  };
}
