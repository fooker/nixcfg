{
  perSystem = { self', inputs', pkgs, config, system, ... }: {
    devShells.default = pkgs.mkShell {
      buildInputs =
        config.pre-commit.settings.enabledPackages ++
        [ config.pre-commit.settings.package ] ++
        [ inputs'.colmena.packages.colmena ] ++
        (with pkgs; [
          bash
          git
          openssh
          gnutar
          gzip

          sops
          age
          ssh-to-age
        ]);

      shellHook = ''
        ${config.pre-commit.installationScript}
        ${config.sops.installationScript}
      '';
    };
  };
}

