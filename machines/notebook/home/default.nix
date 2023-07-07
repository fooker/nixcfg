{ pkgs, inputs, ... }:

{
  programs.home-manager.enable = true;

  services.blueman-applet.enable = true;
  services.pasystray.enable = true;
  services.network-manager-applet.enable = true;

  home.keyboard = {
    layout = "de";
    variant = "nodeadkeys";
  };

  home.packages = with pkgs; [
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
    wdisplays
    wlr-randr

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
    jetbrains.goland
    jetbrains.pycharm-professional
    vscodium

    # Comm
    tdesktop
    signal-desktop
    element-desktop
    discord-ptb
    thunderbird
    mumble
    zoom-us
    teams

    # Remote Desktop
    parsecgaming
    moonlight-qt
    remmina

    # Others
    prusa-slicer
    virt-manager
    steam-run
  ];

  imports = [
    ./bat.nix
    ./firefox.nix
    ./git.nix
    ./gpg.nix
    ./direnv.nix
    ./nextcloud.nix
    ./pass.nix
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

    ./desktop
  ];

  home.stateVersion = "21.03";
}
