{ pkgs, lib, config, ... }:

with lib;

let
  cacheDomain = "nix-cache.open-desk.net";
in
{
  services.hydra = {
    enable = true;

    listenHost = "localhost";
    port = 3001;

    hydraURL = "https://hydra.open-desk.net";

    notificationSender = "noreply@hydra.open-desk.net";

    useSubstitutes = true;
    buildMachinesFiles = [ ];

    extraConfig = ''
      binary_cache_public_uri = https://${cacheDomain}
    '';

    minimumDiskFree = 10;
  };

  services.harmonia = {
    enable = true;

    settings.bind = "[::1]:5005";

    signKeyPath = "/var/lib/harmonia/${cacheDomain}.secret";
  };

  systemd.services.nix-cache-key = {
    enable = true;

    before = [ "harmonia.service" ];
    requiredBy = [ "harmonia.service" ];

    serviceConfig = {
      TimeoutStartSec = "infinity";
      Restart = "on-failure";
      RestartSec = "100ms";
      RemainAfterExit = true;
    };

    script = ''
      set -x
      
      if [[ ! -f /var/lib/harmonia/${cacheDomain}.secret ]]; then
        mkdir -p /var/lib/harmonia
        ${pkgs.nix}/bin/nix-store \
          --generate-binary-cache-key \
          ${cacheDomain}-1 \
          /var/lib/harmonia/${cacheDomain}.secret \
          /var/lib/harmonia/${cacheDomain}.pub
      fi
    '';
  };

  web.reverse-proxy = {
    "hydra" = {
      domains = [ "hydra.open-desk.net" ];
      target = "http://127.0.0.1:${toString config.services.hydra.port}";
    };

    "nix-cache" = {
      domains = [ cacheDomain ];
      target = "http://${config.services.harmonia.settings.bind}";
    };
  };

  gather.parts."builder/nixCacheKey" = {
    name = "${cacheDomain}.pub";
    file = "/var/lib/harmonia/${cacheDomain}.pub";
  };
}
