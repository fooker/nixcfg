{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [ (self: super: {
    mopidy-jellyfin = self.callPackage ./mopidy-jellyfin.nix {};
    mopidy-mpd      = self.callPackage ./mopidy-mpd.nix {};
    mopidy-muse     = self.callPackage ./mopidy-muse.nix {};
    mopidy-somafm   = self.callPackage ./mopidy-somafm.nix {};

    python3 = super.python3.override {
      packageOverrides = self: super: {
        websocket-client = self.callPackage ./websocket-client.nix {};
      };
    };

    python3Packages = self.python3.pkgs;
  })];
}
