{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  services.syncthing  = {
    enable = true;
    openDefaultPorts = true;
  };
}