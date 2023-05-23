{ lib, private, ... }:

with lib;

let
  folders = mapAttrs
    (name: conf: {
      path = "/mnt/syncthing/${ name }";
    } // conf)
    private.syncthing.folders;

in
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;

    inherit (private.syncthing) devices;
    inherit folders;
  };
}
