{ pkgs, inputs, config, ... }:

let
  padwatch = pkgs.callPackage inputs.padwatch { };

in
{
  systemd.services."padwatch" = {
    script = "${padwatch}/bin/padwatch --config ${config.sops.secrets."padwatch/config".path}";
    wantedBy = [ "multi-user.target" ];

    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };

  sops.secrets."padwatch/config" = {
    format = "binary";
    sopsFile = ./secrets/padwatch.toml;
  };
}
