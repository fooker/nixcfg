{ config, lib, pkgs, machineConfig, ... }:

{
  imports = [
    ./modules
  ];

  system.stateVersion = "19.09";
}
