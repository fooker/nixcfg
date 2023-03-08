{ lib, ... }:

with lib;

{
  ## Gives a list of machines by recursively finding machine.nix files
  ## Returns a list of elements containing the path and the id of a machine
  machines =
    let
      walk = id:
        let
          # Path of a (potential) machine
          path = toString (./machines + "/${concatStringsSep "/" id}");

        in
        # Machines must have a machine.nix file
        if builtins.pathExists (path + "/machine.nix")
        then [
          (
            # Read the machine configuration from machine.nix in the machines directory
            (import "${path}/machine.nix") // {
              inherit id path;

              # Build the name of the machine
              name = "${concatStringsSep "-" id}";
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
              (builtins.readDir path)); # Read entries in path
    in
    walk [ ];
}
