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

    # Use our current nixpkgs for local commands
    nix.nixPath = lib.mkForce [
      "nixpkgs=${pkgs.path}"
      "nixpkgs-unstable=${pkgs.unstable.path}"
    ];

    # Register current nixpkgs in flake registry
    nix.registry = {
      "nixpkgs" = {
        from = { type = "indirect"; id = "nixpkgs"; };
        to = { type = "path"; path = pkgs.path; };
      };
      "nixpkgs-unstable" = {
        from = { type = "indirect"; id = "nixpkgs-unstable"; };
        to = { type = "path"; path = pkgs.unstable.path; };
      };
      "nixpkgs-latest" = {
        from = { type = "indirect"; id = "nixpkgs-latest"; };
        to = {
          type = "github";
          owner = "NixOS";
          repo = "nixpkgs";
          reg = "nixpkgs-unstable";
        };
      };
    };
  };
}
