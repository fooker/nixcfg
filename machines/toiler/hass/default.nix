let
  secrets = import ../secrets.nix;
in
{
  default_config = { };

  homeassistant = {
    latitude = 50.55216;
    longitude = 9.68617;
    unit_system = "metric";
    time_zone = "Europe/Berlin";
    name = "Home";
    external_url = "https://hass.home.open-desk.net";
    internal_url = "https://hass.home.open-desk.net";
  };

  http = {
    server_host = "::1";
    server_port = 8123;
    use_x_forwarded_for = true;
    trusted_proxies = "::1";
  };

  mqtt = {
    broker = "127.0.0.1";
    port = 1883;
    client_id = "hass";
    discovery = true;
    discovery_prefix = "homeassistant";
  };

  esphome = { };

  denonavr = { };

  ipp = { };

  discovery = { };

  xiaomi_miio = { };

  mullvad = { };

  mjpeg = { };

  spotify = {
    client_id = secrets.spotify.client.id;
    client_secret = secrets.spotify.client.secret;
  };

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

  automation = [ ];
  script = [ ];
  group = import ./groups.nix;
  scene = import ./scenes.nix;

  switch = [
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
}
