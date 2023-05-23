{ lib
, callPackage
, runCommandNoCCLocal
, ssh-to-age
, ...
}:

with lib;

let
  adminKey = ''3237CA7A1744B4DCE96B409FB4C3BF012D9B26BE'';

  inherit (callPackage ./machines.nix { }) machines;

  sshToKey = name: path: runCommandNoCCLocal "sops-key-${name}.pub" { } ''
    ${ssh-to-age}/bin/ssh-to-age < ${path} > $out
  '';

  machineKeys = listToAttrs (map
    (machine:
      let
        keyFile = sshToKey "machine-${machine.name}" (machine.path + "/gathered/ssh_host_ed25519_key.pub");
      in
      {
        inherit (machine) name;
        value = removeSuffix "\n" (readFile keyFile);
      })
    machines);

  machine_rules =
    let
      # Walk a machine and its parent groups and give a list of all related paths 
      paths = machine:
        let
          walk = e:
            [ e.relPath ] ++ (optionals (e.parent != null) (walk e.parent));
        in
        walk machine;

      # Expand all machines into all related path and assign the machines keys to those paths
      pathKeys = foldAttrs
        concat [ ]
        (map # Build list of { <path> = <key> }
          (machine: listToAttrs (map
            (path: nameValuePair path (singleton (getAttr machine.name machineKeys)))
            (paths machine)))
          machines);

    in
    mapAttrsToList
      (path: keys: {
        "path_regex" = "^${escapeRegex path}/(${escapeRegex "secrets.yaml"}|secrets/.+)$";
        "key_groups" = [{
          "age" = keys;
          "pgp" = [ adminKey ];
        }];
      })
      pathKeys;

in
{
  config = {
    "creation_rules" = machine_rules ++ [{
      "relPath" = "^${escapeRegex "modules/secrets.yaml"}$";
      "key_groups" = [{
        "age" = attrValues machineKeys;
        "pgp" = [ adminKey ];
      }];
    }];
  };
}
