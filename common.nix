{ config, lib, pkgs, machineConfig, ... }:

{
  imports = [
    ./modules

    ./components/boot
    ./components/root.nix
    ./components/network.nix
  ];
}
