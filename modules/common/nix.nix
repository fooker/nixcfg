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

    # Link nixpkgs to etc for usage in NIX_PATH.
    # This allows update to the symlinks when updating nixpkgs without changes
    # to NIX_PATH, which requires a new session to bekome active.
    environment.etc.nixpkgs.source = pkgs.linkFarm "nixpkgs" [
      { name = "nixpkgs"; path = pkgs.path; }
      { name = "nixpkgs-unstable"; path = pkgs.unstable.path; }
    ];

    nix.nixPath = lib.mkForce [
      "nixpkgs=/etc/nixpkgs/nixpkgs"
      "nixpkgs-unstable=/etc/nixpkgs/nixpkgs-unstable"
    ];

    nix.registry = {
      "nixpkgs" = {
        from = { type = "indirect"; id = "nixpkgs"; };
        to = { type = "path"; path = (toString pkgs.path); };
      };
      "nixpkgs-unstable" = {
        from = { type = "indirect"; id = "nixpkgs-unstable"; };
        to = { type = "path"; path = (toString pkgs.unstable.path); };
      };
    };
  };
}
