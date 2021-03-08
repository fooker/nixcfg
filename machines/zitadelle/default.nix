{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ./web.nix
    ./mail.nix
  ];

  # Add a fake "host" entry representing all hosts in this cluster
  config = {
    dns.zones = config.dns.host.domain.parent.mkZone {
      A = config.dns.host.ipv4;
      AAAA = config.dns.host.ipv6;
    };
  };
}
