{ config, ... }:

{
  sops = {
    gnupg.home = "/home/fooker/.gnupg";
  };

  nix.extraOptions = ''
    builders-use-substitutes = true
    !include ${config.sops.secrets."nix/access-tokens".path}

    extra-substituters = https://colmena.cachix.org
    extra-substituters = https://cache.nix.hlsb.hs-fulda.de/hlsb-nixcfg

    extra-trusted-public-keys = colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg=
    extra-trusted-public-keys = hlsb-nixcfg:JCWYhhI49R/+dvIeeBpq3EPdRQ5mGQWp9YBxIV+LYB0=
  '';

  sops.secrets."nix/access-tokens" = {
    format = "binary";
    sopsFile = ../secrets/nix-access-tokens.conf;
  };
}

