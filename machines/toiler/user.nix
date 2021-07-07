{ lib, pkgs, ... }:

with lib;
let
  secrets = import ./secrets.nix;
in
{
  users.users = listToAttrs [
    (nameValuePair secrets.user.username {
      createHome = true;
      isNormalUser = true;

      hashedPassword = secrets.user.hashedPassword;

      openssh.authorizedKeys.keys = secrets.user.authorizedKeys;

      packages = with pkgs; [
        # System
        direnv

        # Editor
        vim

        # Network
        wget
        curl

        # Utils
        file
        gnupg
        htop
        ripgrep
        psmisc
        socat
        tmux
      ];
    })
  ];
}
