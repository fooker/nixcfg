{
  services.gpg-agent = {
    enable = true;

    #pinentryFlavor = "gtk2";
    pinentryFlavor = "gnome3";

    enableSshSupport = true;
    enableScDaemon = false;

    defaultCacheTtl = 7200;
    defaultCacheTtlSsh = 7200;
  };
}
