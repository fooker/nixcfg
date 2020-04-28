{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  services.deluge  = {
    enable = true;
    declarative = true;

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
      "listen_ports" = [ 6242 6242 ];
      "listen_reuse_port" = true;
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
      "random_outgoing_ports" = true;
      "seed_time_limit" = 86400;
      "seed_time_ratio_limit" = 10.0;
      "stop_seed_at_ratio" = true;
      "stop_seed_ratio" = 6.0;
      "torrentfiles_location" = "/mnt/downloads/torrents";
      "upnp" = true;
      "utpex" = true;
    };

    authFile = pkgs.writeText "deluge-auth" ''
      localclient:${secrets.deluge.auth.localclient}:10
    '';

    openFirewall = false; # Via web-interface only

    web = {
      enable = true;
      openFirewall = true; # TODO: Limit to own subnet
    };
  };
}