{ pkgs, ... }:

let
  photonic-scene = pkgs.callPackage ./scene.nix { };

in
{
  systemd.services.photonic = {
    description = "photonic";

    wantedBy = [ "multi-user.target" "network-online.target" ];

    serviceConfig = {
      ExecStart = "${photonic-scene}/bin/photonic";

      Restart = "always";
      RestartSec = 3;

      StateDirectory = "photonic";
    };
  };
}

