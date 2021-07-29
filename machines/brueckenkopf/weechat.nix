{ config, pkgs, ... }:

let
  secrets = import ./secrets.nix;

  weechat = pkgs.weechat.override {
    configure = { availablePlugins, ... }: {
      plugins = with availablePlugins; [ python perl ];
    };
  };

  tmuxConfig = pkgs.writeText "tmux.conf" ''
    set -g default-terminal "screen-256color"
    set -g status off
  '';

in
{
  users = {
    users.weechat = {
      group = "weechat";
      home = "/var/lib/weechat";
      createHome = true;
      isSystemUser = true;
      useDefaultShell = true;

      openssh.authorizedKeys.keys = [
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK2nkarN0+uSuP5sGwDCb9KRu+FCjO/+da4VypGanPUZ''
      ];
    };
    groups.weechat = { };
  };

  networking.extraHosts = secrets.extraHosts;

  systemd.services.weechat = {
    environment.WEECHAT_HOME = config.users.users."weechat".home;

    serviceConfig = {
      User = "weechat";
      Group = "weechat";
      Type = "forking";
      ExecStart = "${pkgs.tmux}/bin/tmux -f ${tmuxConfig} -S /var/lib/weechat/tmux.session new-session -d -s weechat '${weechat}/bin/weechat'";
      ExecStop = "${pkgs.tmux}/bin/tmux -f ${tmuxConfig} -S /var/lib/weechat/tmux.session kill-session -t weechat";
    };

    wantedBy = [ "multi-user.target" ];
    wants = [ "network.target" ];
    after = [ "network.target" ];
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
