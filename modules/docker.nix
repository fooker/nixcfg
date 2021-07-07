{ config, lib, pkgs, tools, ... }:

with lib;

let
  daemon-config = pkgs.writeText "docker-daemon.json" (builtins.toJSON {
    default-address-pools = [
      {
        base = "192.168.132.0/22";
        size = 28;
      }
    ];
  });
in
{
  config = mkIf config.virtualisation.docker.enable {
    virtualisation.docker = {
      package =
        if config.system.nixos.release == "20.09"
        then
          (pkgs.callPackage "${pkgs.path}/pkgs/applications/virtualization/docker" {
            iptables = pkgs.iptables-nftables-compat;
          }).docker_19_03
        else (pkgs.docker.override { iptables = pkgs.iptables-nftables-compat; });

      extraOptions = "--iptables=false --config-file ${ toString daemon-config }";

      autoPrune = {
        enable = true;
        flags = [ "--all" ];
      };
    };

    firewall.rules = dag: with dag; {
      inet.filter.forward = {
        docker = between [ "established" ] [ "drop" ] ''
          ip saddr 192.168.132.0/22
          accept
        '';
      };

      inet.nat.postrouting = {
        docker = anywhere ''
          ip saddr 192.168.132.0/22
          masquerade
        '';
      };
    };
  };
}
