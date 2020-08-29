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

    # CLI tools
    ripgrep
    fd
    bat
    htop
    tmux
    tree
    jq
    unzip unrar

    # Networking
    wireshark
    sshuttle
    magic-wormhole

    # Development
    jetbrains.idea-ultimate
    jetbrains.clion
    vscodium
    rustup
    (callPackage ../../../packages/cargo-embed.nix {})
    (callPackage ../../../packages/cargo-flash.nix {})
    gcc
    
    # Comm
    tdesktop
    thunderbird
    mumble

    # Remote Desktop
    parsecgaming
    remmina

    # Others
    prusa-slicer
    virt-manager

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
    ./scripts.nix
    ./skim.nix
    ./sound.nix
    ./ssh.nix
    ./syncthing.nix
    ./udiskie.nix
    ./vim.nix
    ./zsh.nix
  ];
}
