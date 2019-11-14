{ config, lib, pkgs, machineConfig, ... }:

with lib;
{
  options.commons.nix = {
    enable = mkOption {
        type = types.bool;
        default = true;
    };
  };

  config = mkIf config.commons.nix.enable {
    # Take out the trash
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Optimize the store
    nix.optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };
}
