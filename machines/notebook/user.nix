{ config, lib, pkgs, pkgs-unstable, sources, ... }:

let
  username = "fooker";
  home-manager = (import ../../nix/sources.nix).home-manager;
in {
  imports = [
    "${home-manager}/nixos"
  ];

  home-manager = {
    useGlobalPkgs = true;

    verbose = true;

    users."${username}" = {
      imports = [
        ./home
        { 
          config = {
            _module.args = {
              pkgs-unstable = pkgs-unstable;
            };
          };
        }
      ];
    };
  };

  users.users."${username}" = {
    hashedPassword = "$6$xWl/Id.n98CPWMNw$5NbPhLcjaX3rn699i5zk57z1jLksy3uWdtGH6wNGtMOtBYTDt7OLvH5L.C7o.Jqd0Uztjm/9nttznV5gWncsB0:17335";
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
      "networkmanager"
      "docker"
      "wireshark"
    ];
  };

  nix.trustedUsers = lib.mkOptionDefault [ "fooker" ];

  nixpkgs.pkgs.overlays = [ sources.nixpkgs-mozilla ];
}