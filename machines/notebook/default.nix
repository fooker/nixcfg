{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./network.nix
    ./nix.nix
    ./user.nix
    ./docker.nix
    ./fonts.nix
    ./postgresql.nix
    ./opennms.nix
    ./peering.nix
    ./mounts.nix
    ./libvirt.nix
    ./greet.nix
  ];

  networking.hostName = "r7-a7";

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
    keyMap = "de-latin1-nodeadkeys";
  };

  time.timeZone = "Europe/Berlin";

  security.rtkit.enable = true;

  services.openssh = {
    enable = true;
  };

  services.fwupd = {
    enable = true;
  };

  services.upower = {
    enable = true;
  };

  services.blueman.enable = true;

  services.gvfs.enable = true;

  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  programs.system-config-printer.enable = true;
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      gutenprintBin
      hplip
      splix
    ];
  };

  programs.light.enable = true;

  xdg.portal = {
    enable = true;

    wlr.enable = true;
    wlr.settings = {
      screencast = {
        max_fps = 30;

        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
      };
    };

    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  services.udev = {
    extraRules = ''
      SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-5]", RUN+="${pkgs.systemd}/bin/systemctl hibernate"

      # Training for keyboard
      SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="dialout"
    '';
  };

  services.logind = {
    lidSwitch = "hybrid-sleep";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
    extraConfig = ''
      HandlePowerKey=ignore
    '';
  };

  programs.dconf.enable = true;

  programs.mosh.enable = true;

  programs.noisetorch.enable = true;

  systemd.packages = [ pkgs.blueman ];

  sound = {
    enable = true;
    mediaKeys = {
      enable = true;
      volumeStep = "5%";
    };
  };

  environment.systemPackages = with pkgs; [
    intel-gpu-tools
    libva-utils
    vdpauinfo
    blueman
    lm_sensors

    picocom

    gnupg

    gitAndTools.hub
    gitAndTools.gitFull
    gitAndTools.tig
    gitAndTools.transcrypt

    magic-wormhole

    ntfs3g
    cifs-utils
    nfs-utils
  ];

  boot.kernel.sysctl = {
    # Required by IDEA
    "fs.inotify.max_user_watches" = 524288;
  };

  # No delay for failed login
  security.pam.services.login.nodelay = true;
  security.pam.services.swaylock.nodelay = true;
  security.pam.services.xscreensaver.nodelay = true;
}
