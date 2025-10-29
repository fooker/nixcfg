{
  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-25.05";
    };

    nixpkgs-unstable = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixpkgs-unstable";
    };

    nixpkgs-notebook.follows = "nixpkgs";

    nixpkgs-bitmagnet.follows = "nixpkgs";

    nixpkgs-raketensilo.follows = "nixpkgs-bitmagnet";
    nixpkgs-fliegerhorst.follows = "nixpkgs-bitmagnet";

    nixpkgs-schilderhaus.follows = "nixpkgs-unstable";

    flake-parts = {
      type = "github";
      owner = "hercules-ci";
      repo = "flake-parts";
    };

    disko = {
      type = "github";
      owner = "nix-community";
      repo = "disko";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      type = "github";
      owner = "NixOS";
      repo = "nixos-hardware";
      ref = "master";
    };

    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      ref = "release-25.05";

      inputs.nixpkgs.follows = "nixpkgs-notebook";
    };

    stylix = {
      type = "github";
      owner = "danth";
      repo = "stylix";
      ref = "release-25.05";

      inputs.nixpkgs.follows = "nixpkgs-notebook";
    };

    nixvim = {
      type = "github";
      owner = "nix-community";
      repo = "nixvim";
      ref = "nixos-25.05";
      #ref = "main";

      inputs.nixpkgs.follows = "nixpkgs-notebook";
    };

    nixos-mailserver = {
      type = "git";
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver.git";
      ref = "nixos-25.05";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    bitmagnet = {
      type = "github";
      owner = "fooker";
      repo = "bitmagnet.nix";
    };

    bitmagnet-peers = {
      type = "git";
      url = "git+ssh://git@git.maglab.space/fooker/bitmagnet-peers.git";
      flake = false;
    };

    mmv = {
      type = "github";
      owner = "fooker";
      repo = "mmv";
      flake = false;
    };

    netns-proxy = {
      type = "github";
      owner = "fooker";
      repo = "netns-proxy";
      flake = false;
    };

    qd = {
      type = "github";
      owner = "fooker";
      repo = "qd";
      flake = false;
    };

    photonic = {
      type = "github";
      owner = "fooker";
      repo = "photonic";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    padwatch = {
      type = "github";
      owner = "fooker";
      repo = "padwatch";
      flake = false;
    };

    c3sets-radio = {
      type = "git";
      url = "https://git.maglab.space/fooker/c3sets-radio.git";
      flake = false;
    };

    hasskey = {
      type = "github";
      owner = "fooker";
      repo = "hasskey";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    ipam = {
      type = "github";
      owner = "fooker";
      repo = "ipam.nix";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    dns = {
      type = "github";
      owner = "fooker";
      repo = "dns.nix";

      inputs.ipam.follows = "ipam";
    };

    gather = {
      type = "github";
      owner = "fooker";
      repo = "gather.nix";
    };

    nftables = {
      type = "github";
      owner = "fooker";
      repo = "nftables.nix";
    };

    blog = {
      type = "git";
      url = "https://git.home.open-desk.net/fooker/blog.git";
      flake = false;
    };

    hass-solarman = {
      type = "github";
      owner = "StephanJoubert";
      repo = "home_assistant_solarman";
      flake = false;
    };

    nixago = {
      type = "github";
      owner = "nix-community";
      repo = "nixago";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks-nix = {
      type = "github";
      owner = "cachix";
      repo = "git-hooks.nix";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops = {
      type = "github";
      owner = "Mic92";
      repo = "sops-nix";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      type = "github";
      owner = "zhaofengli";
      repo = "colmena";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    private = {
      url = "git+file:private";
      flake = false;
    };

    work-utils = {
      type = "gitlab";
      host = "git.rz.hs-fulda.de";
      owner = "fdhlb212";
      repo = "personal-utils";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    ucware-client = {
      type = "gitlab";
      host = "git.rz.hs-fulda.de";
      owner = "fdhlb212";
      repo = "ucware-client.nix";

      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { flake-parts, ... }@inputs: flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      inputs.git-hooks-nix.flakeModule

      ./dev.nix
      ./machines.nix
      ./sops.nix
      ./hive.nix
    ];

    systems = [
      "x86_64-linux"
    ];
  };
}
