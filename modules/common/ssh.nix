{ lib, config, nodes, ... }:

with lib;

{
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
