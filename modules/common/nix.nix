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
    # Living on the edge
    nix.package = pkgs.unstable.nixUnstable;
    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';

    # Take out the trash
    nix.gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 30d";
    };

    # Optimize the store
    nix.optimise = {
      automatic = true;
      dates = [ "monthly" ];
    };

    # Who cares about licenses?
    nixpkgs.config.allowUnfree = true;
  };
}
