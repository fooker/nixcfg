{ config, lib, pkgs, ... }:

# TODO: Open firewall

with lib;
let
  mmv = with pkgs; rustPlatform.buildRustPackage rec {
    name = "mmv";

    src = builtins.fetchGit {
      url = "https://github.com/fooker/mmv.git";
      ref = "master";
    };

    cargoSha256 = "02947g85hy3di6wf5wb04vyx4pzckkcc02v9nap7m70rdr9jxzkf";
  };
in {
  environment.systemPackages = [
    mmv
  ];
}