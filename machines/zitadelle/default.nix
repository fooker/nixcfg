{ config, options, lib, ... }:

with lib;

{
  imports = [
    ./web.nix
    ./mail.nix
  ];

  options = {
    # The significant other for every member of the cluster
    hive.spouse = options.hive.self;
  };

  # Add a fake "host" entry representing all hosts in this cluster
  config = {
    dns.zones = config.dns.host.domain.parent.mkRecords {
      A = config.dns.host.ipv4;
      AAAA = config.dns.host.ipv6;
    };
  };
}
