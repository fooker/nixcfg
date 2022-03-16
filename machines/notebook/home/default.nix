{ pkgs, ... }:

{
  programs.home-manager.enable = true;

  services.blueman-applet.enable = true;
  services.pasystray.enable = true;

  home.keyboard = {
    layout = "de";
    variant = "nodeadkeys";
  };

  home.packages = with pkgs; [
    ate

    direnv
    lorri

    # Sound and media
    pavucontrol
    ponymix
    playerctl
    spotify
    mpv

    # GUI tools
    qalculate-gtk
    evince
    mate.eom
    unstable.gimp
    unstable.inkscape
    libreoffice
    vorta
    unstable.obsidian

    # CLI tools
    ripgrep
    fd
    bat
    htop
    tmux
    tree
    jq
    unzip
    unrar

    # Networking
    wireshark
    sshuttle
    magic-wormhole

    # Development
    jetbrains.idea-ultimate
    jetbrains.clion
    jetbrains.pycharm-professional
    vscodium

    # Comm
    tdesktop
    signal-desktop
    element-desktop
    thunderbird
    mumble
    zoom-us

    # Remote Desktop
    parsecgaming
    remmina

    # Others
    prusa-slicer
    virt-manager
    steam-run

    # Xorg stuff
    xorg.xdriinfo
    xorg.xkill
  ];

  imports = [
    ./autorandr.nix
    ./bat.nix
    ./dunst.nix
    ./firefox.nix
    ./git.nix
    ./gpg.nix
    ./i3wm.nix
    ./lorri.nix
    ./nextcloud.nix
    ./pass.nix
    ./redshift.nix
    ./retro.nix
    ./scripts.nix
    ./skim.nix
    ./sound.nix
    ./ssh.nix
    ./syncthing.nix
    ./udiskie.nix
    ./vim.nix
    ./vorta.nix
    ./zsh.nix
  ];

  home.stateVersion = "21.03";
}
