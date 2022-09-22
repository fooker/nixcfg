{ config, lib, pkgs, ... }:

with lib;

{
  options.hive.glusterfs = {
    enable = mkOption {
      type = types.bool;
      description = "Enable this host as a glusterfs node";
      default = true;
    };

    volumes = mkOption {
      type = types.listOf types.str;
      description = "List of volumes to mount on this host";
      default = [ ];
    };
  };

  config = mkIf (config.hive.enable && config.hive.glusterfs.enable) {
    services.glusterfs = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      glusterfs
    ];

    systemd.services = {
      "gluster-peers" = {
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "gluster-peers" ''
            set -eu

            ${concatMapStringsSep "\n"
              (node: "${pkgs.glusterfs}/bin/gluster peer probe ${toString node.address.ipv4}")
              (attrValues config.hive.nodes)
            }

            ${pkgs.glusterfs}/bin/gluster peer status
          '';
          RemainAfterExit = true;
        };
        after = [ "glusterd.service" ];
        requires = [ "glusterd.service" ];
      };
    } //
    (listToAttrs (map
      (volume: nameValuePair "gluster-volume-${volume}" {
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "gluster-volume-${volume}-init" ''
            set -eu

            if ! ${pkgs.glusterfs}/bin/gluster volume info ${volume}; then
              ${pkgs.glusterfs}/bin/gluster volume create ${volume} \
                replica ${toString (length (attrNames config.hive.nodes))} \
                ${concatMapStringsSep " "
                  (node: "${toString node.address.ipv4}:/data/${volume}")
                  (attrValues config.hive.nodes)
                }
            fi

            ${pkgs.glusterfs}/bin/gluster volume start ${volume} force
          '';
          RemainAfterExit = true;
        };
        before = [ "srv-${volume}.mount" ];
        requiredBy = [ "srv-${volume}.mount" ];
        partOf = [ "srv-${volume}.mount" ];
        after = [ "glusterd.service" "gluster-peers.service" ];
        requires = [ "glusterd.service" "gluster-peers.service" ];
      })
      config.hive.glusterfs.volumes));

    fileSystems = listToAttrs (map
      (volume: nameValuePair "/srv/${volume}" {
        device = "localhost:/${volume}";
        fsType = "glusterfs";
        noCheck = true;
        options = [ "noatime,_netdev" ];
      })
      config.hive.glusterfs.volumes);

    firewall.rules = dag: with dag; {
      inet.filter.input = {
        gluster = between [ "established" ] [ "drop" ] ''
          ip saddr { ${ concatMapStringsSep "," (node: toString node.address.ipv4) (attrValues config.hive.nodes) } }
          tcp dport { 24007, 24008, 49152 - 60999}
          accept
        '';
      };
    };
  };
}
