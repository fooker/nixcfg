{ lib, pkgs, ... }:

let
  secrets = import ../secrets.nix;
in {
  default_config = {};
  homeassistant = {
    latitude = 50.55216;
    longitude = 9.68617;
    unit_system = "metric";
    time_zone = "Europe/Berlin";
    name = "Home";
  };

  http = {
    server_host = "::1";
    server_port = 8123;
    base_url = "http://hass.home.open-desk.net";
    use_x_forwarded_for = true;
    trusted_proxies = "::1";
  };

  mqtt = {
    broker = "127.0.0.1";
    port = 1883;
    client_id = "hass";
  };

  esphome = {};

  camera = [
    {
      platform = "mjpeg";
      mjpeg_url = "http://prusa.home.open-desk.net/webcam?action=stream";
      still_image_url = "http://prusa.home.open-desk.net/webcam?action=snapshot";
    }
  ];

  octoprint = {
    host = "prusa.home.open-desk.net";
    api_key = secrets.prusa.api_key;
    bed = true;
  };

  automation = [];
  script = [];
  group = import ./groups.nix;
  scene = import ./scenes.nix;

  switch = [
    {
      platform = "mqtt";

      name = "Projector";
      icon = "mdi:projector";

      command_topic = "frisch/home/esper/cc690b/projector/set";
      payload_on = "1";
      payload_off = "0";

      state_topic = "frisch/home/esper/cc690b/projector/target";
      state_on = "1";
      state_off = "0";

      availability_topic = "frisch/home/esper/cc690b/status";
      payload_available = "ONLINE";
      payload_not_available = "OFFLINE";
    }
    {
      platform = "mqtt";
      
      name = "Screen";
      icon = "mdi:projector-screen";

      command_topic = "frisch/home/esper/9e90e5/screen/set";
      payload_on = "LOWER";
      payload_off = "RAISE";
      
      state_topic = "frisch/home/esper/9e90e5/screen";
      state_on = "LOWER";
      state_off = "RAISE";
      
      availability_topic = "frisch/home/esper/9e90e5/status";
      payload_available = "ONLINE";
      payload_not_available = "OFFLINE";
    }
  ];

  media_player = [
    {
      platform = "denonavr";

      name = "Amp";
      host = "172.23.200.133";

      show_all_sources = false;
    }
  ];
}