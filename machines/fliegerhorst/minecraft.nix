{ config, ... }:

{
  services.minecraft-server = {
    enable = true;
    eula = true;
    jvmOpts = "-Xms7G -Xmx7G";
    declarative = true;
    serverProperties = {
      server-port = 25565;
      motd = "Das sind nicht die Droiden die ihr sucht.";

      level-name = "Überwelt";
      difficulty = "easy";
      gamemode = "creative";
      force-gamemode = true;
      pvp = false;

      allow-flight = true;
      allow-nether = true;

      white-list = true;
      enforce-whitelist = true;
    };

    whitelist = {
      "der_wahre_luke" = "970f2e10-5c92-447d-a90b-ea2697215094";
      "inkthebard" = "acb9ef40-2930-4625-a52b-6702a24d36cc";
    };
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      minecraft = between [ "established" ] [ "drop" ] [
        ''tcp dport ${toString config.services.minecraft-server.serverProperties.server-port} accept''
      ];
    };
  };

  dns.zones = {
    org.open-desk.mc = {
      CNAME = config.dns.host.domain;
    };
  };
}

