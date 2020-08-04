{ config, lib, pkgs, ... }:

with lib;
{
  options.common.nix = {
    enable = mkOption {
        type = types.bool;
        default = true;
    };
  };

  config = mkIf config.common.nix.enable {
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

    # Who cares about licenses?
    nixpkgs.config.allowUnfree = true;
  };
}
