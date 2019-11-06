{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.networking.ppp;
in {
  options = {
    networking.ppp = {
      enable = mkEnableOption "ppp client service";

      peers = mkOption {
        type = types.attrsOf (types.submodule ({
          options = {
            username = mkOption {
              type    = types.str;
              default = "";
              description = ''
                  <literal>username</literal> of the ppp connection.
              '';
            };
            password = mkOption {
              type    = types.str;
              default = "";
              description = ''
                  <literal>password</literal> of the ppp connection.
              '';
            };
            interface = mkOption {
              type = types.str;
              description = "Interface which the ppp connection will use.";
            };
            pppoe = mkEnableOption "pppoe plugin";
            debug = mkEnableOption "debug mode";
            extraOptions = mkOption {
              type = types.lines;
              default = "";
              description = "Extra ppp connection options";
            };
          };
        }));

        default = {};
      };
    };
  };

  config = mkIf cfg.enable rec {
    systemd.services =
      mapAttrs' (name: cfg: nameValuePair "ppp-${name}" {
        description = "PPP peer ${name}";
        wantedBy = [ "network.target" ];

        serviceConfig = {
          ExecStart = "${pkgs.ppp}/sbin/pppd call ${name} nodetach nolog";
        };

        restartTriggers = [
          config.environment.etc."ppp/peers/${name}".source
        ];
      }) cfg.peers;
    
     environment.etc =
      mapAttrs' (name: cfg: nameValuePair "ppp/peers/${name}" {
        text = concatStringsSep "\n" [
          (optionalString cfg.pppoe "plugin rp-pppoe.so ${cfg.interface}")
          "linkname ${name}"
          "user \"${cfg.username}\""
          "password \"${cfg.password}\""
          "${cfg.extraOptions}"
          (optionalString cfg.debug "debug")
        ];
      }) cfg.peers;
  };
}
