{ config, pkgs, lib, inputs, device, network, private, ... }:

with lib;

{
  services.mosquitto = {
    enable = true;

    listeners = [
      {
        port = 1883;

        omitPasswordAuth = true;

        # TODO: Use real ACLs (with patterns and users) here
        settings.allow_anonymous = true;
        acl = [
          "topic readwrite #"
        ];

        users = { };
      }
    ];

    settings = {
      "autosave_interval" = 10;
      "autosave_on_changes" = false;
    };
  };

  services.home-assistant = {
    enable = true;

    config = import ./hass { inherit lib private; };

    extraComponents = [
      "default_config"
      "lovelace"
      "mqtt"
      "esphome"
      "denonavr"
      "apple_tv"
      "ipp"
      "mjpeg"
      "mpd"
      "snapcast"
      "spotify"
      "media_player"
      "vacuum"
      "weather"
      "prusalink"
      "upnp"
      "wled"
      "zha"
    ];

    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      mini-media-player
      valetudo-map-card
    ];
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ENV{ID_VENDOR_ID}=="10c4", ENV{ID_MODEL_ID}=="ea60", ENV{ID_SERIAL_SHORT}="00_12_4B_00_25_9A_E3_4A", SYMLINK+="zigbee"
  '';

  systemd.tmpfiles.rules = [
    "C /var/lib/hass/custom_components/solarman - - - - ${inputs.hass-solarman}/custom_components/solarman"
    "Z /var/lib/hass/custom_components 770 hass hass - -"
  ];

  services.zigbee2mqtt = {
    enable = true;
    settings = {
      permit_join = false;

      frontend = {
        port = 8034;
        host = "::1";
        url = "https://zigbee.home.open-desk.net";
      };

      homeassistant = true;
      availability = true;

      serial = {
        port = "/dev/zigbee";
      };

      mqtt = {
        server = "mqtt://localhost:1883";
        base_topic = "frisch/home/zigbee";
        client_id = "zigbee2mqtt";
      };
    };
  };

  web.reverse-proxy = {
    "hass" = {
      domains = [ "hass.home.open-desk.net" ];
      target = "http://[::1]:8123/";
    };
    "zigbee" = {
      domains = [ "zigbee.home.open-desk.net" ];
      target = "http://[::1]:8034";
    };

    # Reverse proxy prusa MK4 web interface to add SSL
    # This is required to embed the web interface in hass with SSL enforcment in iframes
    "prusa" = {
      domains = [ "prusa.home.open-desk.net" ];
      target = "http://${(head network.devices.prusa.effectiveAddresses).address}";
    };
  };

  systemd.services.hasskey = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    script =
      let
        inherit (inputs.hasskey.packages.${config.nixpkgs.system}) hasskey;
        configFile = pkgs.writers.writeJSON "hasskey.config" {
          home-assistant = {
            url = "https://hass.home.open-desk.net/";
            token.path = config.sops.secrets."hasskey/token".path;
          };

          devices = [
            {
              name = "zonk";
              filter = {
                ID_INPUT_KEYBOARD = "1";
                ID_BUS = "bluetooth";
                NAME = "ZONK Keyboard";
              };
            }
            {
              name = "dumbpad";
              filter = {
                ID_INPUT_KEYBOARD = "1";
                NAME = "imchipwood dumbpad Keyboard";
              };
            }
          ];
        };
      in
      "${hasskey}/bin/hasskey -v -v -v -v --config ${configFile}";
  };

  environment.systemPackages = with pkgs; [ mosquitto ];

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      mqtt = between [ "established" ] [ "drop" ] ''
        meta iifname {iot, priv}
        tcp dport 1883
        accept
      '';
    };
  };

  dns.zones = {
    net.open-desk.home.iot = {
      mqtt = { A = device.interfaces.iot.address.ipv4.address; };
      deploy = { A = device.interfaces.iot.address.ipv4.address; };
    };
  };

  backup.jobs."hass".paths = [
    config.services.home-assistant.configDir
    config.services.mosquitto.dataDir
    config.services.zigbee2mqtt.dataDir
  ];

  sops.secrets."hasskey/token" = { };
}
