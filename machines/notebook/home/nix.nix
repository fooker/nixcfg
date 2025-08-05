{ config, ... }:

{
  sops = {
    gnupg.home = "/home/fooker/.gnupg";
  };

  nix.extraOptions = ''
    builders-use-substitutes = true
    !include ${config.sops.secrets."nix/access-tokens".path}
  '';

  sops.secrets."nix/access-tokens" = {
    format = "binary";
    sopsFile = ../secrets/nix-access-tokens.conf;
  };
}

