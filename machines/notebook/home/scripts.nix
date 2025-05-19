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

  telefonliste =
    let
      script = pkgs.fetchurl {
        url = "https://gist.githubusercontent.com/fooker/db6948cb3c3551e5516dd6c875f6de05/raw/14e779c692ab928f7e652d2cfc0175707daedf73/telefonliste.py";
        hash = "sha256-qaoADs77gNBfo5/TLf8n+bDlezSaat3/2h7mxSQHrnI=";
      };
    in
    pkgs.writers.writePython3Bin "telefonliste"
      {
        flakeIgnore = [ "E265" ];
        libraries = with pkgs.python3Packages; [
          requests
          pandas
          openpyxl
          click
          unidecode
          thefuzz
        ];
      }
      script;

in
{
  home.packages = [
    weechat-connect
    c3radio
    tmpsh
    telefonliste
  ];
}
