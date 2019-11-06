{ machine }: 
  let
    lib = import ./lib.nix;
    machineConfig = lib.config machine;
    nixpkgs = builtins.fetchTarball (with import ./nixpkgs.nix; {
      url = "https://github.com/${owner}/${repo}/archive/${branch}.tar.gz";
    });
    nixos = import "${nixpkgs}/nixos" {
      configuration = {
        _module.args = {
          inherit machine machineConfig;
        };
        
        imports = [
          ./common.nix
          (lib.path machine)
        ];
      };

      system = "${machineConfig.system}";
    };
  in
    nixos.system
