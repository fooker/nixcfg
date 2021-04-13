{ config, lib, pkgs, ... }:

let
  weechat = pkgs.weechat.override {
    configure = { availablePlugins, ... }: {
      plugins = with availablePlugins; [ python perl ];
    };
  };

in {
  users = {
    groups.weechat = {};
    users.weechat = {
      createHome = true;
      group = "weechat";
      home = "/var/lib/weechat";
      isSystemUser = true;
    };
  };

  systemd.services.weechat = {
    environment.WEECHAT_HOME = config.users.users."weechat".home;
    
    serviceConfig = {
      User = "weechat";
      Group = "weechat";
    };
    
    script = "exec ${pkgs.tmux}/bin/tmux -L weechat -2 new-session -d -s weechat -n weechat '${weechat}/bin/weechat'";
    
    wantedBy = [ "multi-user.target" ];
    wants = [ "network.target" ];
  };

  reverse-proxy.hosts = {
    "weechat" = {
      domains = [ "weechat.open-desk.net" ];
      target = "http://127.0.0.1:9000";
    };
  };

  backup.paths = [
    config.users.users."weechat".home
  ];
}
