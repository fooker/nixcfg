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

  nix.package = pkgs.lix;

  networking.hostName = "r7-a7";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "de_DE.UTF-8/UTF-8" ];
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
    nssmdns4 = true;
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

  services.udev = {
    extraRules = ''
      SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-5]", RUN+="${pkgs.systemd}/bin/systemctl hibernate"

      # Flash Support for Xiao M0
      ATTRS{idVendor}=="2886", ENV{ID_MM_DEVICE_IGNORE}="1"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2886", MODE="0666"
      SUBSYSTEM=="tty", ATTRS{idVendor}=="2886", MODE="0666"

      # hidraw interface: Bluetooth (=0005), PS Move Motion Controller (=054c:03d5)
      SUBSYSTEM=="hidraw", KERNELS=="0005:054C:03D5.*", MODE="0666"

      # hidraw interface: USB (=0003), PS Move Motion Controller (=054c:03d5)
      SUBSYSTEM=="hidraw", KERNELS=="0003:054C:03D5.*", MODE="0666"

      # hidraw interface: Bluetooth (=0005), PS4 Move Motion Controller, CECH-ZCM2 (=054c:0c5e)
      SUBSYSTEM=="hidraw", KERNELS=="0005:054C:0C5E.*", MODE="0666"

      # hidraw interface: USB (=0003), PS4 Move Motion Controller, CECH-ZCM2 (=054c:0c5e)
      SUBSYSTEM=="hidraw", KERNELS=="0003:054C:0C5E.*", MODE="0666"
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

  programs.wireshark.enable = true;

  systemd.packages = [ pkgs.blueman ];

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
    "fs.inotify.max_user_instances" = 512;
  };

  services.gnome.gnome-keyring.enable = true;

  # No delay for failed login
  security.pam.services.login.nodelay = true;
  security.pam.services.swaylock.nodelay = true;
  security.pam.services.xscreensaver.nodelay = true;

  environment.stub-ld.enable = false;
}
