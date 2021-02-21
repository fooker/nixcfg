{ ... }:

let
  sources = import ../nix/sources.nix;

  # Use the unmodified host nixpkgs for all tools
  pkgs = import sources.nixpkgs {
    config = {};
  };

  tools = {
    ipinfo = pkgs.callPackage ./ipinfo.nix {};
  };
in {
  _module.args = {
    inherit tools;
  };
}
