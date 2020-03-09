{ lib, pkgs, name, sources, ... }@args:

let
  tools = {
    ipinfo = import ./ipinfo.nix args;
  };
in {
  _module.args = {
    inherit tools;
  };
}
