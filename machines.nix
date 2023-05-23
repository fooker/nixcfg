{ lib, ... }:

with lib;

{
  ## Gives a list of machines by recursively finding machine.nix files
  ## Returns a list of elements containing the path and the id of a machine
  machines =
    let
      path = id: rec {
        # Relative path for the id
        relPath = "machines/${concatStringsSep "/" id}";

        # Absoulte path (could be a store path)
        absPath = ./. + "/${relPath}";
      };

      # Parent entry for the given ID
      parent = id:
        if id == [ ]
        then null
        else {
          inherit id;
          inherit (path id) relPath absPath;
          parent = parent (init id);
        };

      walk = id:
        let
          inherit (path id) relPath absPath;

          # Path of a (potential) machine.nix file
          machineFile = absPath + "/machine.nix";

        in
        # Machines must have a machine.nix file
        if builtins.pathExists machineFile
        then [
          (
            # Read the machine configuration from machine.nix in the machines directory
            (import machineFile) // {
              inherit id relPath machineFile;

              # The absoulte path of the machine as a nix store path
              path = absPath;

              # Build the name of the machine
              name = "${concatStringsSep "-" id}";

              # Parent entries for the record
              parent = parent (init id);
            }
          )
        ]
        else
          concatLists
            (mapAttrsToList
              (entry: type:
                # Filter for entries which are sub-directories and recurse into sub-directory while append sub-directory name to machine name
                if type == "directory"
                then walk (id ++ [ entry ])
                else [ ])
              (builtins.readDir absPath)); # Read entries in path
    in
    walk [ ];
}
