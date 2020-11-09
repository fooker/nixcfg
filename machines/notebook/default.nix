{ config, lib, pkgs, sources, ... }:

let
  secrets = import ./secrets.nix;
in {
  imports = [
    ./hardware.nix
    ./network.nix
    ./nix.nix
    ./user.nix
    ./docker.nix
    ./fonts.nix
    ./ate.nix
    ./postgresql.nix
    ./parsecgaming.nix
    ./opennms.nix
    ./xserver.nix
    ./backhaul.nix
    ./mounts.nix
  ];

  nixpkgs.pkgs.overlays = [ sources.nixpkgs-mozilla ];

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

  services.gvfs.enable = true;

  services.printing.enable = true;

  services.autorandr = {
    enable = true;
    defaultTarget = "mobile";
  };

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
}
