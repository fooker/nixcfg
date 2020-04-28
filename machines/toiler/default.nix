{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  imports = [
    ./hardware.nix
    ./network.nix
  ];

  server.enable = true;

  users.users."fooker" = {
    createHome = true;
    isNormalUser = true;

    hashedPassword = "$6$3S/rgJ8.Dz7ak$UeqTgpMfIVAZK3.82QgisbZFmyhPE1f9JNEACx8agIJkNIPECNY5cXaqCiTFxo0PRM/Jhch/qjVLlpCH1C/Lr.";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK2nkarN0+uSuP5sGwDCb9KRu+FCjO/+da4VypGanPUZ fooker@k-2so"
    ];

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
  };
}
