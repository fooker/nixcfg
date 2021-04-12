{ config, lib, pkgs, ... }:

let
  username = "fooker";
  sources = import ../../nix/sources.nix;
in {
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
    hashedPassword = "$6$xWl/Id.n98CPWMNw$5NbPhLcjaX3rn699i5zk57z1jLksy3uWdtGH6wNGtMOtBYTDt7OLvH5L.C7o.Jqd0Uztjm/9nttznV5gWncsB0";
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

  backup.paths = [
    "/home/fooker"
  ];
}
