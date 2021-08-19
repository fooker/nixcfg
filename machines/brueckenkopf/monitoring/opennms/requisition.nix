{ lib, pkgs, network, nodes, ... }:

with lib;

let
  secrets = import ../../secrets.nix;

  nodes' = mapAttrsToList
    (name: node:
      rec {
        inherit name;
        inherit (node.config.monitoring) label id;

        device = network.devices."${name}";

        location = optionalString
          (device.site != null)
          device.site.name;

        interfaces = concatLists (mapAttrsToList
          (name: interface: map
            (address: {
              inherit name address;

              services = map
                (service: {
                  inherit (service) name;
                })
                (filter
                  (service: service.interfaces == null || elem interface.name service.interfaces)
                  node.config.monitoring.services);
            })
            interface.effectiveAddresses)
          device.interfaces);
      })
    nodes;

  requisition = pkgs.writeText "requisition.xml" ''
    <model-import
        xmlns="http://xmlns.opennms.org/xsd/config/model-import"
        foreign-source="nixos">
      ${concatMapStringsSep "\n" (node: ''
      <node
          node-label="${node.label}"
          foreign-id="${node.id}"
          location="${node.location}">
        ${concatMapStringsSep "\n" (interface: ''
        <interface
            ip-addr="${toString interface.address.address}"
            descr="${interface.name}"
            status="1"
            snmp-primary="N">
          ${concatMapStringsSep "\n" (service: ''
          <monitored-service
            service-name="${service.name}"/>
          '') interface.services}
        </interface>
        '') node.interfaces}
      </node>
      '') nodes'}
    </model-import>
  '';
in
{
  systemd.services."opennms-requisition" = {
    wants = [ "opennms.service" ];
    after = [ "opennms.service" ];

    wantedBy = [ "multi-user.target" ];

    script = ''
      ${pkgs.curl}/bin/curl \
        -v \
        -u "deploy:${secrets.opennms.deploy.password}" \
        -X POST \
        -H 'Content-type: application/xml' \
        -d @${requisition} \
        http://localhost:8980/opennms/rest/requisitions

        ${pkgs.curl}/bin/curl \
          -v \
          -u "deploy:${secrets.opennms.deploy.password}" \
          -X PUT \
          http://localhost:8980/opennms/rest/requisitions/nixos/import
    '';

    restartTriggers = [ requisition ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  environment.etc."requisition" = {
    target = "nixos-requisition.xml";
    source = requisition;
  };
}
