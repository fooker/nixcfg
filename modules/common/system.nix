{ config, lib, pkgs, ... }:

with lib;
{
  programs = {
    vim.defaultEditor = true;

    tmux = {
      enable = true;
      terminal = "screen-256color";
      newSession = true;
    };
  };

  services.timesyncd = mkDefault {
    enable = true;
    servers = [
      "0.nixos.pool.ntp.org" "1.nixos.pool.ntp.org" "2.nixos.pool.ntp.org" "3.nixos.pool.ntp.org"
      "81.7.16.52" "185.220.101.34" "213.239.239.165" "46.4.34.242"
    ];
  };

  services.journald.extraConfig = ''
    SystemMaxUse=50M
    MaxRetentionSec=1week
  '';

  environment.systemPackages = with pkgs; [
    # Editor
    vim

    # Network
    wget
    curl
    nmap
    tcpdump
    ldns
    whois
    mtr
    iw
    sipcalc
    openssl

    # Utils
    file
    gnupg
    htop
    iotop
    iftop
    ripgrep
    psmisc
    socat
    tmux
    fd
    ripgrep

    # Hardware
    pciutils
    usbutils

    # Filesystems
    cryptsetup
  ];
}
