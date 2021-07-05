{ config, lib, pkgs, path, ... }:

with lib;

let
  fingerprint = file: fileContents (pkgs.runCommandNoCCLocal "" {} ''
    cat ${/. + file} \
      | awk '{print $2}' \
      | ${pkgs.openssl}/bin/openssl base64 -d -A \
      | ${pkgs.openssl}/bin/openssl sha256 \
      | awk '{print $2}' \
      > $out
  '');
in {
  options.server = {
    enable = mkOption {
        type = types.bool;
        default = false;
    };
  };

  config = mkIf config.server.enable {
    services.openssh = {
      enable = true;
      passwordAuthentication = false;
    };

    firewall.rules = dag: with dag; {
      inet.filter.input = {
        ssh = between ["established"] ["drop"] ''
          tcp
          dport 22
          accept
        '';
      };
    };

    dns.zones = mkIf (config.dns.host != null) (config.dns.host.domain.mkRecords {
      SSHFP = [
        {
          algorithm = "rsa";
          hash = "sha256";
          fingerprint = fingerprint ("${path}/gathered/ssh_host_rsa_key.pub");
        }
        {
          algorithm = "ed25519";
          hash = "sha256";
          fingerprint = fingerprint ("${path}/gathered/ssh_host_ed25519_key.pub");
        }
      ];
    });
  };
}
