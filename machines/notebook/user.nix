{ pkgs, ... }:

let
  username = "fooker";
  sources = import ../../nix/sources.nix;
  secrets = import ./secrets.nix;
in
{
  imports = [
    "${sources.home-manager}/nixos"
  ];

  home-manager = {
    useGlobalPkgs = true;

    verbose = true;

    users."${username}" = {
      imports = [
        ./home
      ];
    };
  };

  users.users."${username}" = {
    inherit (secrets.users.fooker) hashedPassword;
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "audio"
      "input"
      "kvm"
      "render"
      "video"
      "dialout"
      "docker"
      "wireshark"
      "libvirtd"
    ];
  };

  backup.extraPublicKeys = {
    "fooker" = ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK2nkarN0+uSuP5sGwDCb9KRu+FCjO/+da4VypGanPUZ'';
  };
}
