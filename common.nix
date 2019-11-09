{ config, lib, pkgs, machineConfig, ... }:

{
  imports = [
    ./modules

    ./modules/nix.nix
    ./modules/boot
    ./modules/root.nix
    ./modules/network
  ];

  system.stateVersion = "19.09";
}
