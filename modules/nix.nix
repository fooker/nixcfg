{ config, lib, pkgs, machineConfig, ... }:

{
  # Take out the trash
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Optimize the store
  nix.optimise = {
    automatic = true;
    dates = "weekly";
  };
}
