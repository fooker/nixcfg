{ config, lib, pkgs, ... }:

with lib;

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

    fileSystems = {
      "/srv/http" = {
        device = "localhost:/http";
        fsType = "glusterfs";
        noCheck = true;
        options = [ "_netdev" ];
      };
    };

    firewall.rules = dag: with dag; {
      inet.filter.input = {
        gluster = between [ "established" ] [ "drop" ] ''
          ip saddr { ${ concatMapStringsSep "," (node: node.address.ipv4) (attrValues config.hive.nodes) } }
          tcp dport { 24007 - 24009, 49152 - 49154}
          accept
        '';
      };
    };
  };
}
