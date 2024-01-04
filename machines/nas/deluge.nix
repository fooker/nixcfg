{ config, lib, pkgs, inputs, private, ... }:

with lib;

let
  netns-proxy = pkgs.callPackage ../../packages/netns-proxy.nix { inherit inputs; };

in
{
  services.deluge = {
    enable = true;
    declarative = true;

    package = pkgs.deluge-2_x;

    config = {
      "add_paused" = false;
      "allow_remote" = false;
      "auto_managed" = true;
      "copy_torrent_file" = true;
      "daemon_port" = 58846;
      "del_copy_torrent_file" = false;
      "dht" = true;
      "dont_count_slow_torrents" = true;
      "download_location" = "/mnt/downloads/incoming";
      "enabled_plugins" = [
        "Extractor"
      ];
      "listen_interface" = "";
      "listen_ports" = [ private.deluge.forwardedPort private.deluge.forwardedPort ];
      "listen_reuse_port" = true;
      "outgoing_ports" = [ private.deluge.forwardedPort private.deluge.forwardedPort ];
      "max_active_downloading" = 10;
      "max_active_limit" = 100;
      "max_active_seeding" = 100;
      "max_connections_global" = 200;
      "max_connections_per_second" = 20;
      "max_connections_per_torrent" = -1;
      "max_download_speed" = -1.0;
      "max_download_speed_per_torrent" = -1;
      "max_half_open_connections" = 50;
      "max_upload_slots_global" = 4;
      "max_upload_slots_per_torrent" = -1;
      "max_upload_speed" = -1.0;
      "max_upload_speed_per_torrent" = -1;
      "move_completed" = true;
      "move_completed_path" = "/mnt/downloads/finished/unsorted";
      "natpmp" = true;
      "new_release_check" = false;
      "random_port" = false;
      "random_outgoing_ports" = false;
      "seed_time_limit" = 86400;
      "seed_time_ratio_limit" = 10.0;
      "stop_seed_at_ratio" = true;
      "stop_seed_ratio" = 6.0;
      "torrentfiles_location" = "/mnt/downloads/torrents";
      "upnp" = true;
      "utpex" = true;
    };

    authFile = config.sops.secrets."deluge/auth".path;

    web = {
      enable = true;
    };
  };

  systemd.services."deluge-netns" = {
    description = "Deluge BitTorrent Daemon - Network Namespace";
    after = [ "network.target" ];
    wantedBy = [ "network.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;

      ExecStartPre = [
        "-${ pkgs.iproute }/bin/ip netns delete deluge"
      ];

      ExecStart = [
        "${ pkgs.iproute }/bin/ip netns add deluge"

        "${ pkgs.iproute }/bin/ip -n deluge link set lo up"
      ];

      ExecStop = [
        "${ pkgs.iproute }/bin/ip netns delete deluge"
      ];
    };
  };

  systemd.services."deluge-wg" = {
    description = "Deluge BitTorrent Daemon - Wireguard Tunnel";
    after = [ "network.target" "deluge-netns.service" ];
    bindsTo = [ "deluge-netns.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;

      ExecStartPre = [
        "-${ pkgs.iproute }/bin/ip -n deluge link delete dev deluge"
      ];

      ExecStart = [
        "${ pkgs.kmod }/bin/modprobe wireguard"

        "${ pkgs.iproute }/bin/ip link add dev deluge type wireguard"
        "${ pkgs.iproute }/bin/ip link set dev deluge netns deluge"

        "${ pkgs.iproute }/bin/ip -n deluge link set dev deluge up"
        "${ pkgs.iproute }/bin/ip -n deluge addr add dev deluge ${private.deluge.wg.address.ipv4}"
        "${ pkgs.iproute }/bin/ip -n deluge addr add dev deluge ${private.deluge.wg.address.ipv6}"
        "${ pkgs.iproute }/bin/ip -n deluge route replace 0.0.0.0/0 dev deluge table main"
        "${ pkgs.iproute }/bin/ip -n deluge route replace ::0/0 dev deluge table main"

        "${ pkgs.iproute }/bin/ip netns exec deluge ${ pkgs.wireguard-tools }/bin/wg setconf deluge ${config.sops.secrets."deluge/wg/config".path}"
      ];

      ExecStop = [
        "${ pkgs.iproute }/bin/ip -n deluge link delete dev deluge"
      ];
    };

    wantedBy = [ "multi-user.target" ];
  };

  systemd.services."deluged-proxy" = {
    after = [ "deluge-netns.service" "deluged.service" ];
    bindsTo = [ "deluge-netns.service" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${ netns-proxy }/bin/netns-proxy -b 127.0.0.1:58846 deluge 127.0.0.1:58846";
      Restart = "on-failure";
    };

    wantedBy = [ "multi-user.target" ];
  };

  systemd.services."deluged" = {
    after = [ "deluge-netns.service" ];
    bindsTo = [ "deluge-netns.service" ];

    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/deluge";
    };
  };

  boot.extraModulePackages = optional (versionOlder config.boot.kernelPackages.kernel.version "5.6") config.boot.kernelPackages.wireguard;

  web.reverse-proxy = {
    "deluge" = {
      domains = [ "deluge.home.open-desk.net" ];
      target = "http://127.0.0.1:${ toString config.services.deluge.web.port }/";
    };
  };

  sops.secrets."deluge/auth" = {
    owner = "deluge";
  };
  sops.secrets."deluge/wg/config" = {
    format = "binary";
    sopsFile = ./secrets/deluge-wg.conf;
  };
}
