{ pkgs, ... }:

let
  sources = import ../../../nix/sources.nix;
  photonic = pkgs.unstable.callPackage sources.photonic { };

  scene = ./scene.dhall;

in
{
  users = {
    users."photonic" = {
      group = "photonic";
      isSystemUser = true;
    };
    groups."photonic" = { };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="spidev", KERNEL=="spidev0.0", TAG+="systemd", GROUP:="photonic", SYMLINK+="ledstrip"
  '';

  systemd.services."photonic" = {
    description = "photonic";

    requires = [ "dev-ledstrip.device" ];
    after = [ "dev-ledstrip.device" ];

    serviceConfig = {
      Type = "simple";

      User = "photonic";
      Group = "photonic";

      ExecStart = ''${photonic}/bin/photonic-run \
        ${scene} \
        --fps 60 \
        --interface grpc:127.0.0.1:5764
      '';
    };

    wantedBy = [ "multi-user.target" ];
  };

  environment.systemPackages = [ photonic ];
}
