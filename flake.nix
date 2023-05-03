{
  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-22.11";
    };

    nixpkgs-unstable = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixpkgs-unstable";
    };

    nixpkgs-notebook = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-22.11";
    };

    nixpkgs-magnetico = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixpkgs-unstable";
    };

    nixpkgs-raketensilo.follows = "nixpkgs-magnetico";
    nixpkgs-fliegerhorst.follows = "nixpkgs-magnetico";

    nixpkgs-toiler.follows = "nixpkgs-unstable";

    utils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
    };

    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      ref = "release-22.11";
    };

    nixos-mailserver = {
      type = "git";
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver.git";
      ref = "nixos-22.11";
    };

    magnetico = {
      type = "git";
      url = "git+ssh://git@git.darmstadt.ccc.de/btdht/mldht2elastic.git";
      ref = "elasticsearch2";
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

    ipam = {
      type = "path";
      path = "/home/fooker/devl/ipam.nix/";
    };

    dns = {
      type = "path";
      path = "/home/fooker/devl/dns.nix/";
      inputs.ipam.follows = "ipam";
    };

    ate = {
      type = "github";
      owner = "andir";
      repo = "ate";
      flake = false;
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

    pre-commit-hooks = {
      type = "github";
      owner = "cachix";
      repo = "pre-commit-hooks.nix";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      type = "github";
      owner = "zhaofengli";
      repo = "colmena";

      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, utils, pre-commit-hooks, colmena, ... }@inputs: {
    colmena = import ./deployment.nix inputs;

    devShell = utils.lib.eachSystemMap utils.lib.allSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        hooks = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
            statix.enable = true;
            shellcheck.enable = true;
          };
        };
      in
      pkgs.mkShell {
        buildInputs = [
          colmena.defaultPackage.${system}
        ] ++ (with pkgs; [
          bash
          gitAndTools.git
          gitAndTools.transcrypt
          gnutar
          gzip
          nixUnstable
          openssh
          drone-cli
          nixpkgs-fmt
          nix-linter
          shellcheck
        ]);

        inherit (hooks) shellHook;
      });
  };
}
