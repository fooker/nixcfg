{
  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-23.05";
    };

    nixpkgs-unstable = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixpkgs-unstable";
    };

    nixpkgs-notebook.follows = "nixpkgs";

    nixpkgs-magnetico.follows = "nixpkgs-unstable";

    nixpkgs-raketensilo.follows = "nixpkgs-magnetico";
    nixpkgs-fliegerhorst.follows = "nixpkgs-magnetico";

    nixpkgs-router.follows = "nixpkgs-unstable";
    nixpkgs-toiler.follows = "nixpkgs-unstable";

    nixpkgs-schilderhaus.follows = "nixpkgs-unstable";

    nixos-hardware = {
      type = "github";
      owner = "NixOS";
      repo = "nixos-hardware";
      ref = "master";
    };

    utils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
    };

    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      ref = "release-23.05";

      inputs.nixpkgs.follows = "nixpkgs-notebook";
    };

    stylix = {
      type = "github";
      owner = "danth";
      repo = "stylix";
      ref = "release-23.05";

      inputs.nixpkgs.follows = "nixpkgs-notebook";
      inputs.home-manager.follows = "home-manager";
    };

    nixos-mailserver = {
      type = "git";
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver.git";
      ref = "nixos-23.05";
    };

    magnetico = {
      type = "git";
      url = "https://git.darmstadt.ccc.de/btdht/magnetico.nix.git";
      ref = "main";
      submodules = true;
      flake = false;
    };

    magnetico-peers = {
      type = "git";
      url = "git+ssh://git@git.darmstadt.ccc.de/btdht/peers.git";
      flake = false;
    };

    ipinfo = {
      type = "github";
      owner = "fooker";
      repo = "ipinfo";
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
      flake = false;
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

    ipam = {
      type = "path";
      path = "/home/fooker/devl/ipam.nix/";
    };

    dns = {
      type = "path";
      path = "/home/fooker/devl/dns.nix/";
      inputs.ipam.follows = "ipam";
    };

    gather = {
      type = "path";
      path = "/home/fooker/devl/gather.nix/";
    };

    nftables = {
      type = "path";
      path = "/home/fooker/devl/nftables.nix/";
    };

    blog = {
      type = "git";
      url = "https://git.home.open-desk.net/fooker/blog.git";
      flake = false;
    };

    schoen-und-gut = {
      type = "git";
      url = "https://git.home.open-desk.net/schoen-und-gut/website.git";
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
      inputs.flake-utils.follows = "utils";
    };

    pre-commit-hooks = {
      type = "github";
      owner = "cachix";
      repo = "pre-commit-hooks.nix";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops = {
      type = "github";
      owner = "Mic92";
      repo = "sops-nix";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    colmena = {
      type = "github";
      owner = "zhaofengli";
      repo = "colmena";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    private = {
      url = "git+file:./private";
      flake = false;
    };
  };

  outputs = { nixpkgs, utils, ... }@inputs: {
    colmena = import ./deployment.nix inputs;

    devShell = utils.lib.eachSystemMap utils.lib.allSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        colmena = inputs.colmena.defaultPackage.${system}.overrideAttrs (final: prev: {
          patchs = (prev.patches or [ ]) ++ [
            ./patches/colmena-disable-ssh-master.patch
          ];
        });

        pre-commit-hooks = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
            statix.enable = true;
            shellcheck.enable = true;
          };
        };

        sops-hooks = inputs.nixago.lib.${system}.make {
          data = (pkgs.callPackage ./sops.nix { }).config;
          output = ".sops.yaml";
          format = "yaml";
        };
      in
      pkgs.mkShell {
        buildInputs = [
          colmena
        ] ++ (with pkgs; [
          bash
          gitAndTools.git
          gnutar
          gzip
          sops
          age
          nixUnstable
          openssh
          drone-cli
          nixpkgs-fmt
          statix
          shellcheck
        ] ++ [
          (pkgs.vscode-with-extensions.override {
            vscode = pkgs.vscodium;
            vscodeExtensions = with pkgs.vscode-extensions; [
              bbenoist.nix
            ];
          })
        ]);

        shellHook = ''
          ${pre-commit-hooks.shellHook}
          ${sops-hooks.shellHook}
        '';
      });
  };
}
