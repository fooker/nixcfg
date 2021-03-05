{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ./web.nix
  ];

  # Add a fake "host" entry representing all hosts in this cluster
  config = {
    dns.zones = setAttrByPath (init config.dns.host.domain) {
      A = config.dns.host.ipv4;
      AAAA = config.dns.host.ipv6;
    };
  };
}
