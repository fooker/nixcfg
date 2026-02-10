{
  self,
  lib,
  inputs,
  flake-parts-lib,
  ...
}:

with lib;

{
  config.perSystem = ({ ... }: {
    sops.adminKey = ''3237CA7A1744B4DCE96B409FB4C3BF012D9B26BE'';
  });

  options = {
    perSystem = flake-parts-lib.mkPerSystemOption ({ config, options, pkgs, system, ... }: {
      options.sops =
      let
        # Groups values from a list of attrsets by key.
        # Each key in any input attrset becomes a key in the output,
        # with its values collected into a list in input order.
        groupValues = foldAttrs (item: acc: [item] ++ acc) [ ];
    
        # Walk a machine and its parent groups and give a list of all related paths 
        machinePaths = machine: optionals (machine != null)
          ([ machine.relPath ] ++ (machinePaths machine.parent));
    
        # Convert the SSH public key of a machine to an AGE key
        machineKey = machine:
          let
            path = /${machine.path}/gathered/ssh_host_ed25519_key.pub;
            keyFile = pkgs.runCommandLocal "sops-key-${machine.name}.pub" { } ''
              ${pkgs.ssh-to-age}/bin/ssh-to-age < ${path} > $out
            '';
          in
          if builtins.pathExists path
          then removeSuffix "\n" (readFile keyFile)
          else null;
        
        # Expand all machines into all related path and assign the machines keys to those paths
        pathKeys = groupValues (map 
          # For each machine, build an attrset mapping all relevant paths to the machine key
          (machine: 
            let
              paths = machinePaths machine;
              key = machineKey machine;
            in
              optionalAttrs
                (key != null)
                (listToAttrs
                  (map (path: nameValuePair path key) paths)))
          (attrValues self.lib.machines));

        sopsRules = mapAttrsToList
          (path: keys: {
            "path_regex" = "^${escapeRegex path}/(secrets\.yaml|secrets/.+)$";
            "key_groups" = [{
              "age" = keys;
              "pgp" = [ config.sops.adminKey ];
            }];
          })
          pathKeys;
    
      in {
        adminKey = mkOption {
          type = types.str;
          description = "AGE key of the admin";
        };

        installationScript = mkOption {
          type = types.str;
          description = "A bash fragment that sets up a SOPS config";
          default = (inputs.nixago.lib.${system}.make {
            data = {
              "creation_rules" = sopsRules;
            };
            output = ".sops.yaml";
            format = "yaml";
          }).shellHook;
          defaultText = lib.literalMD "bash statements";
          readOnly = true;
        };
      };
    });
  };
}
