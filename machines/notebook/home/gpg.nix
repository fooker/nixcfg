{ pkgs, ... }: {
  services.gpg-agent = {
    enable = true;

    pinentry.package = pkgs.pinentry-gnome3;

    enableSshSupport = true;
    enableScDaemon = false;

    defaultCacheTtl = 7200;
    defaultCacheTtlSsh = 7200;
  };
}
