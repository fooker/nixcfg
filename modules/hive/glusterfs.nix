{ config, lib, pkgs, ... }:

with lib;

let
  mounts = [
    "http"
    "calendar"
  ];
in
{
  options.hive.glusterfs = {
    enable = mkOption {
      type = types.bool;
      description = "glusterfs node";
      default = true;
    };
  };

  config = mkIf (config.hive.enable && config.hive.glusterfs.enable) {
    services.glusterfs = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      glusterfs
    ];

    fileSystems = listToAttrs (map
      (mount: nameValuePair "/srv/${mount}" {
        device = "localhost:/${mount}";
        fsType = "glusterfs";
        noCheck = true;
        options = [ "noatime,_netdev" ];
      })
      mounts);

    firewall.rules = dag: with dag; {
      inet.filter.input = {
        gluster = between [ "established" ] [ "drop" ] ''
          ip saddr { ${ concatMapStringsSep "," (node: toString node.address.ipv4) (attrValues config.hive.nodes) } }
          tcp dport { 24007 - 24009, 49152 - 49154}
          accept
        '';
      };
    };
  };
}
