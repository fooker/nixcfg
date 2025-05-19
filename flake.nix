{
  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-24.11";
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

    utils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
    };

    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      ref = "release-24.11";

      inputs.nixpkgs.follows = "nixpkgs-notebook";
    };

    stylix = {
      type = "github";
      owner = "danth";
      repo = "stylix";
      ref = "release-24.11";

      inputs.nixpkgs.follows = "nixpkgs-notebook";
      inputs.home-manager.follows = "home-manager";
    };

    nixvim = {
      type = "github";
      owner = "nix-community";
      repo = "nixvim";
      ref = "nixos-24.11";
      #ref = "main";

      inputs.nixpkgs.follows = "nixpkgs-notebook";
      inputs.home-manager.follows = "home-manager";
    };

    nixos-mailserver = {
      type = "git";
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver.git";
      ref = "master";

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

      inputs.flake-utils.follows = "utils";
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

      inputs.flake-utils.follows = "utils";
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
  };

  outputs = { self, nixpkgs, utils, colmena, ... }@inputs: {
    colmena = import ./deployment.nix inputs;
    colmenaHive = colmena.lib.makeHive self.colmena;

    # hydraJobs = {
    #   deployment = self.colmenaHive.toplevel;
    # };
  } // (utils.lib.eachDefaultSystem (system: {
    apps.pxe-installer =
      let
        installer = node: nixpkgs.legacyPackages.${system}.callPackage ./pxe-installer.nix {
          inherit node;
        };
      in
      builtins.mapAttrs
        (_: node: {
          type = "app";
          program = toString (installer node);
        })
        self.colmenaHive.nodes;

    devShells.default =
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
      };
  }));
}
