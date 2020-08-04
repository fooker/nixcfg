{ pkgs, ... }:

let
  weechat-connect = pkgs.writeScriptBin "weechat-connect" (with pkgs; ''
    #!${stdenv.shell}

    exec ${mosh}/bin/mosh "weechat@weechat.open-desk.net" -- \
      screen -A -x "weechat"
  '');
in {
  home.packages = [
    weechat-connect
  ];
}