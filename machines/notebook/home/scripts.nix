{ pkgs, ... }:

let
  weechat-connect = pkgs.writeScriptBin "weechat-connect" ''
    exec ${pkgs.mosh}/bin/mosh "weechat@weechat.open-desk.net" -- \
      tmux -S /var/lib/weechat/tmux.session attach-session -t weechat
  '';

  c3radio = pkgs.writeScriptBin "c3radio" ''
    selected=$(ls -d -1 /mnt/vault/downloads/c3sets/by-id/* | shuf | head -n 1)
    echo "Playing $selected"

    ${pkgs.mpv}/bin/mpv "$selected"
  '';

  tmpsh = pkgs.writeScriptBin "tmpsh" ''
    TMPSH="$(mktemp -d)"
    trap 'rm -rf -- "$TMPSH"' EXIT

    (
      cd "$TMPSH"
      exec "$SHELL"
    )
  '';
in
{
  home.packages = [
    weechat-connect
    c3radio
    tmpsh
  ];
}
