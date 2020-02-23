{
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

  group = [];
  automation = [];
  script = [];
  scene = import ./scenes.nix;

  cover = [
    {
      platform = "mqtt";
      
      name = "screen";
      device_class = "shade";

      command_topic = "frisch/home/esper/9e90e5/screen/set";
      payload_open = "RAISE";
      payload_close = "LOWER";
      payload_stop = null;
      
      state_topic = "frisch/home/esper/9e90e5/screen";
      state_open = "RAISE";
      state_closed = "LOWER";
      
      availability_topic = "frisch/home/esper/9e90e5/status";
      payload_available = "ONLINE";
      payload_not_available = "OFFLINE";
    }
  ];

  media_player = [
    {
      platform = "denonavr";

      host = "172.23.200.133";
      name = "amp";

      show_all_sources = false;
    }
  ];
}