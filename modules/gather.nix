{ lib, pkgs, config, path, ... }:

with lib;

let
  gatherList = pkgs.writeText "gather-list" (concatMapStringsSep "\n"
    (part: part.name)
    (attrValues config.gather));

  gatherScript = pkgs.writeShellScript "gather" ''
    set -o errexit
    set -o nounset
    set -o pipefail

    SCRATCH="$(mktemp -d)"
    trap 'rm -rf -- "$SCRATCH"' EXIT

    cd "$SCRATCH"

    ${concatMapStringsSep "\n"
      (part: ''
        mkdir -p "$(dirname "${part.name}")"
        ${optionalString (part.file != null) ''
          cp -f "${part.file}" "${part.name}"
        ''}
        ${optionalString (part.command != null) ''
          "${part.command}" > "${part.name}"
        ''}
      '')
      (attrValues config.gather)}

    ${pkgs.gnutar}/bin/tar c --dereference --files-from "${gatherList}"
  '';

in
{
  options.gather = mkOption {
    description = ''

    '';
    type = types.attrsOf (types.submodule ({ name, config, ... }: {
      options = {
        name = mkOption {
          description = ''
            File name to gather from system.
          '';
          type = types.str;
          default = name;
        };

        file = mkOption {
          description = ''
            Path of the file to gether.
          '';
          type = types.nullOr types.path;
          apply = mapNullable toString;
          default = null;
        };

        command = mkOption {
          description = ''
            Command to run for output to gether.
          '';
          type = types.nullOr types.package;
          default = null;
        };

        target = mkOption {
          description = ''
            Target path to copy the gathered data to.
          '';
          type = types.str;
          readOnly = true;
          default = "${path}/gathered/${config.name}";
        };
      };
    }));
    default = { };
  };

  config = {
    system.activationScripts.gather = ''
      #!${pkgs.runtimeShell}

      ln -sfn "${gatherScript}" /run/gather
    '';

    assertions = mapAttrsToList
      (name: part: {
        assertion = length (filter (s: s != null) [ part.file part.command ]) == 1;
        message = "Exactly one of `gather.${name}.file` and `gather.${name}.command` must be set.";
      })
      config.gather;
  };
}
