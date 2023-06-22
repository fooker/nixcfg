{ pkgs, lib, config, inputs, ... }:

with lib;

let
  c3sets-radio = pkgs.callPackage inputs.c3sets-radio { };

in
{
  systemd.services."c3sets-fetch" = {
    script = "${c3sets-radio}/bin/c3sets-fetch /mnt/downloads/c3sets";
    startAt = "6:20";
    requires = [ "network-online.target" ];
  };
}
