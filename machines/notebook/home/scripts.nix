{ pkgs, ... }:

let
  weechat-connect = pkgs.writeScriptBin "weechat-connect" (with pkgs; ''
    #!${stdenv.shell}

    exec ${mosh}/bin/mosh "weechat@weechat.open-desk.net" -- \
      tmux -S /var/lib/weechat/tmux.session attach-session -t weechat
  '');
in
{
  home.packages = [
    weechat-connect
  ];
}
