{ lib, pkgs, network, nodes, config, ... }:

with lib;

let
  nodes' = mapAttrsToList
    (name: device: {
      inherit (device.monitoring) id;

      label = name;

      location = optionalString
        (device.site != null)
        device.site.name;

      interfaces = concatLists (mapAttrsToList
        (name: interface: map
          (address: {
            inherit name address;

            services = map
              (service: {
                inherit (service) name meta;
              })
              ((filter
                (service: service.interfaces == null || elem interface.name service.interfaces)
                (optionals (nodes ? ${name}) nodes.${name}.config.monitoring.services))
              ++ interface.monitoring.services);
          })
          interface.effectiveAddresses)
        device.interfaces);
    })
    network.devices;

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
            service-name="${service.name}">
            ${concatStringsSep "\n" (mapAttrsToList (name: value: ''
              <meta-data context="x-nixos" key="${name}" value="${value}" />
            '') service.meta)}
          </monitored-service>
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
        -u "deploy:$(cat "${config.sops.secrets."opennms/deploy/password".path}")" \
        -X POST \
        -H 'Content-type: application/xml' \
        -d @${requisition} \
        http://localhost:8980/opennms/rest/requisitions

        ${pkgs.curl}/bin/curl \
          -v \
          -u "deploy:$(cat "${config.sops.secrets."opennms/deploy/password".path}")" \
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

  sops.secrets."opennms/deploy/password" = { };
}
