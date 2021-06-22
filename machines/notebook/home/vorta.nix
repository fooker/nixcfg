{ pkgs, ... }:

{
  systemd.user.services.vorta = {
    Unit = {
      Description = "vorta - A GUI for BorgBackup";
    };

    Service = {
      Type = "forking";
      ExecStart = "${pkgs.vorta}/bin/vorta --daemonize";
    };
  };
}