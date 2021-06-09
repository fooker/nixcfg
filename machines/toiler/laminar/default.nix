{ config, lib, pkgs, path, ... }:

with lib;

let
  secrets = import ./secrets.nix;

  # Creates a directory containing all the files related to a single job
  mkJob = name: job: let

    # Creates an element for a link specifying a job part
    # The part can either be an derivation as a derivation or will be converted into an executable script
    mkPart = part: let
      value = job."${ part }";
    in {
      name = "${ name }.${ part }";
      path = if isDerivation value
        then value
        else pkgs.writeShellScript "laminar-job-${ name }.${ part }" ''
          set -e

          ${ value }
        '';
    };

    # Create a element for a link adding a key-value config file
    # Each entry in the config is written out as KEY=VALUE entry
    mkConfigFile = part: config: {
      name = "${ name }.${ part }";
      path = pkgs.writeText "laminar-job-${ name }.${ part }"
        (concatStringsSep "\n"
          (mapAttrsToList
            (key: value: "${ key }=${ value }")
            config));
    };

  in pkgs.linkFarm "laminar-job-${ name }" ([
    (mkPart "run")
    (mkConfigFile "conf" (job.config or {}))
    (mkConfigFile "env" (job.environment or {}))
  ]
  ++ (optional (job ? "init") (mkPart "init"))
  ++ (optional (job ? "before") (mkPart "before"))
  ++ (optional (job ? "after") (mkPart "after")));

  # Collect jobs from ./jobs directory
  # Each job file can contain a single job or a list of jobs.
  jobs = pkgs.symlinkJoin {
    name = "laminar-jobs";
    paths = (concatMap
      (mapAttrsToList mkJob)
      (mapAttrsToList
        (entry: type: (pkgs.callPackages (./jobs + "/${ entry }") {
          inherit secrets;
        }))
        (builtins.readDir ./jobs)));
  };

  # Collect scripts from ./scripts directory
  # Each script is an attrset from name to script
  scripts = pkgs.linkFarm "laminar-scripts"
    (concatMap
      (mapAttrsToList (name: path: {
        inherit name path;
      }))
      (mapAttrsToList
        (entry: type: (pkgs.callPackages (./scripts + "/${ entry }") {
          inherit secrets;
        }))
        (builtins.readDir ./scripts)));

  cfg = pkgs.linkFarm "laminar-cfg-dir" [
    { name = "scripts"; path = scripts; }
    { name = "jobs"; path = jobs; }
  ];

in {
  users = {
    groups.laminar = { };
    users.laminar = {
      group = "laminar";
      home = "/var/lib/laminar";
      createHome = true;
      isSystemUser = true;
    };
  };

  systemd.services.laminar = {
    enable = true;
    description = "Laminar continuous integration service";
    
    environment = {
      LAMINAR_HOME = config.users.users."laminar".home;
      LAMINAR_TITLE = "open-desk CI";
    };

    serviceConfig = {
      DynamicUser = false;
      WorkingDirectory = config.users.users."laminar".home;
      ExecStart = "${ pkgs.laminar }/bin/laminard";
      User = "laminar";
      StateDirectory = "laminar";
      LimitNOFILE = "1024000";
    };

    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    preStart = ''
      ln -sfT '${ cfg }' '${ config.users.users."laminar".home }/cfg'
    '';
  };

  reverse-proxy.hosts = {
    "laminar" = {
      domains = [ "laminar.home.open-desk.net" "ci.home.open-desk.net" ];
      target = "http://[::1]:8080";
    };
  };

  environment.systemPackages = [ pkgs.laminar ];

  backup = {
    paths = [
      config.users.users."laminar".home
    ];
  };
}
