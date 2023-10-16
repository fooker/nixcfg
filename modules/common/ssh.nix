{ pkgs, lib, config, nodes, ... }:

with lib;

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      ssh = between [ "established" ] [ "drop" ] ''
        tcp dport 22
        accept
      '';
    };
  };

  dns.zones = mkIf (config.dns.host != null) (config.dns.host.domain.mkRecords {
    SSHFP =
      let
        # TODO: Use gather script, not IFD
        fingerprint = file: fileContents (pkgs.runCommandNoCCLocal "" { } ''
          cat '${file}' \
            | awk '{print $2}' \
            | ${pkgs.openssl}/bin/openssl base64 -d -A \
            | ${pkgs.openssl}/bin/openssl sha256 \
            | awk '{print $2}' \
            > $out
        '');
      in
      [
        {
          algorithm = "rsa";
          hash = "sha256";
          fingerprint = fingerprint config.gather.parts."ssh/hostKey/rsa".path;
        }
        {
          algorithm = "ed25519";
          hash = "sha256";
          fingerprint = fingerprint config.gather.parts."ssh/hostKey/ed25519".path;
        }
      ];
  });

  gather.parts = {
    "ssh/hostKey/rsa" = {
      name = "ssh_host_rsa_key.pub";
      file = "/etc/ssh/ssh_host_rsa_key.pub";
    };
    "ssh/hostKey/ed25519" = {
      name = "ssh_host_ed25519_key.pub";
      file = "/etc/ssh/ssh_host_ed25519_key.pub";
    };
  };

  services.openssh.knownHosts = mapAttrs'
    (name: node: {
      name = "host-${name}";
      value = {
        hostNames = [ node.config.dns.host.domain.toSimpleString ];
        publicKey = fileContents node.config.gather.parts."ssh/hostKey/ed25519".path;
      };
    })
    (filterAttrs
      (_: node: node.config.server.enable)
      nodes);
}
