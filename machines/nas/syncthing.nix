{ config, lib, pkgs, ... }:

with lib;
let
  secrets = import ./secrets.nix;

  devices = secrets.syncthing.devices;

  folders = mapAttrs
    (name: conf: {
      path = "/mnt/syncthing/${ name }";
    } // conf)
    secrets.syncthing.folders;

in {
  services.syncthing  = {
    enable = true;
    openDefaultPorts = true;
    declarative = {
      inherit devices folders;
    };
  };
}
