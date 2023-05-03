{ lib, ... }:

with lib;

let
  importDir = path:
    concatLists
      (mapAttrsToList
        (entry: type:
          assert assertMsg (type == "regular") "${toString entry} is not a regular file";
          (toFunction (import "${path}/${entry}")) { inherit lib; })
        (builtins.readDir path));

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

  media_player = [
    {
      platform = "snapcast";
      host = "127.0.0.1";
    }
    {
      platform = "mpd";
      host = "127.0.0.1";
    }
  ];

  input_boolean = {
    heater_automation = {
      name = "Enable heater automations";
      icon = "mdi:thermostat-auto";
    };
  };

  "automation desc" = importDir ./automations;
  "automation ui" = "!include automations.yaml";

  #"script desc" = importDir ./scripts;
  "script ui" = "!include scripts.yaml";

  "group decl" = importDir ./groups;
  "group ui" = "!include groups.yaml";

  "scene decl" = importDir ./scenes;
  "scene ui" = "!include scenes.yaml";
}
