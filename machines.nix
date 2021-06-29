{ lib, ... }:

with lib;

{
  ## Gives a list of machines by recursively finding machine.nix files
  ## Returns a list of elements containing the path and the id of a machine
  machines = let
    walk = id: let
      # Path of a (potential) machine
      relPath = "machines/${concatStringsSep "/" id}";
      absPath = "${toString ./.}/${relPath}";
    in
      # Machines must have a machine.nix file
      if (builtins.pathExists "${absPath}/machine.nix" )
      then [ {
        inherit id relPath absPath;
        name = "${concatStringsSep "-" (id)}"; # Build the name of the machine
      } ]
      else concatLists
        (mapAttrsToList
          (entry: type:
            # Filter for entries which are sub-directories and recurse into sub-directory while append sub-directory name to machine name
            if type == "directory"
              then walk (id ++ [ entry ])
              else [])
          (builtins.readDir absPath)); # Read entries in path
  in walk [];
}