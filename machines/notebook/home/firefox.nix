{ pkgs, ... }:

{
  programs.librewolf = {
    enable = true;
    package = pkgs.librewolf;

    languagePacks = [
      "en-GB"
      "de"
    ];

    settings = {
      "webgl.disabled" = false;

      "cookiebanners.service.mode.privateBrowsing" = 2;
      "cookiebanners.service.mode" = 2;

      "privacy.donottrackheader.enabled" = true;

      "privacy.fingerprintingProtection" = true;
      "privacy.resistFingerprinting" = false;

      "privacy.trackingprotection.emailtracking.enabled" = true;
      "privacy.trackingprotection.enabled" = true;
      "privacy.trackingprotection.fingerprinting.enabled" = true;
      "privacy.trackingprotection.socialtracking.enabled" = true;

      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.cookies" = false;

      "network.cookie.lifetimePolicy" = 0;
    };
  };
}
