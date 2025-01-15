{ pkgs, inputs, ... }:

let
  craneLib = inputs.photonic.craneLib.${pkgs.system};

  photonic-scene = craneLib.callPackage ./scene.nix { };

in
{
  systemd.services.photonic = {
    description = "photonic";

    wantedBy = [ "multi-user.target" "network-online.target" ];

    serviceConfig = {
      ExecStart = "${photonic-scene}/bin/photonic-scene";

      Restart = "always";
      RestartSec = 3;

      StateDirectory = "photonic";
    };
  };
}

