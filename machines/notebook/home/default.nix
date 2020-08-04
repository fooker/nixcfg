{ pkgs, ... }: 

{
  programs.home-manager.enable = true;

  services.blueman-applet.enable = true;
  services.pasystray.enable = true;

  home.keyboard = {
    layout = "de";
    variant = "latin1";
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
    networkmanagerapplet
    evince

    # CLI tools
    ripgrep
    fd
    bat
    htop
    tmux
    tree
    jq

    # Networking
    wireshark
    sshuttle
    magic-wormhole

    # Development
    unstable.jetbrains.idea-ultimate
    unstable.jetbrains.clion
    unstable.vscodium
    unstable.rustup
    unstable.gcc
    
    # Comm
    tdesktop
    thunderbird
    mumble
  ];

  imports = [
    ./autorandr.nix
    ./bat.nix
    ./firefox.nix
    ./git.nix
    ./gpg.nix
    ./kanshi.nix
    ./lorri.nix
    ./mako.nix
    ./pass.nix
    ./redshift.nix
    ./rofi.nix
    ./scripts.nix
    ./skim.nix
    ./sound.nix
    ./ssh.nix
    ./sway.nix
    ./syncthing.nix
    ./udiskie.nix
    ./vim.nix
    ./zsh.nix
  ];
}
