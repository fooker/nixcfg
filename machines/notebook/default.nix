{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  imports = [
    ./hardware.nix
    ./network.nix
    ./user.nix
    ./docker.nix
    ./fonts.nix
    ./ate.nix
    ./docker.nix
  ];

  networking.hostName = "ig-11";

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

  services.hardware.bolt.enable = true;

  services.tlp = {
    enable = true;
    extraConfig = ''
      CPU_SCALING_GOVERNOR_ON_AC=performance
      CPU_SCALING_GOVERNOR_ON_BAT=powersave

      START_CHARGE_THRESH_BAT0=60
      STOP_CHARGE_THRESH_BAT0=100
      
      WIFI_PWR_ON_AC=off
      WIFI_PWR_ON_BAT=off
    '';
  };

  services.gvfs.enable = true;

  services.printing.enable = true;

  services.udev = {
    extraRules = ''
      SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-5]", RUN+="${pkgs.systemd}/bin/systemctl hibernate"
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

  programs.sway.enable = true;

  programs.dconf.enable = true;
  
  programs.mosh.enable = true;

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
    blueman

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
}
