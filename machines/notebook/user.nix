{ pkgs
, config
, nodes
, inputs
, machine
, device
, network
, ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;

    verbose = true;

    sharedModules = [
      inputs.sops.homeManagerModules.sops
    ];


    users."fooker" = {
      imports = [
        ./home
      ];
    };

    extraSpecialArgs = {
      inherit nodes inputs machine device network;
    };
  };

  users.users."fooker" = {
    isNormalUser = true;
    uid = 1000;

    shell = pkgs.zsh;

    hashedPasswordFile = config.sops.secrets."users/fooker/password".path;

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
      "networkmanager"
      "wireshark"
    ];
  };

  sops.secrets."users/fooker/password" = {
    neededForUsers = true;
  };
}
