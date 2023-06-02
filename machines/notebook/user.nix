{ pkgs
, config
, inputs
, machine
, device
, network
, ...
}:

{
  imports = [
    "${inputs.home-manager}/nixos"
  ];

  home-manager = {
    useGlobalPkgs = true;

    verbose = true;

    users."fooker" = {
      imports = [
        ./home
      ];
    };

    extraSpecialArgs = {
      inherit inputs machine device network;
    };
  };

  users.users."fooker" = {
    isNormalUser = true;
    uid = 1000;

    shell = pkgs.zsh;

    passwordFile = config.sops.secrets."users/fooker/password".path;

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

  sops.secrets."users/fooker/password" = {
    neededForUsers = true;
  };
}
