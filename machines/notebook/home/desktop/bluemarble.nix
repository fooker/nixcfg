{ pkgs, ... }:

let
  url = "https://eumetview.eumetsat.int/static-images/latestImages/EUMETSAT_MSGIODC_RGBNatColourEnhncd_FullResolution.jpg";

  bluemarble = pkgs.writers.writeBashBin "bluemarble" ''
    set -e
    set -u
    set -o pipefail
    
    ${pkgs.curl}/bin/curl -sLf '${url}' \
    | ${pkgs.imagemagick}/bin/magick jpg:- \
      -crop 0x0+0-580 \
      -resize 2880x1800 \
      -gravity center \
      -background black \
      -extent 2880x1800 \
      jpg:- \
    | ${pkgs.swww}/bin/swww img - \
      --resize fit \
      --transition-type simple \
      --transition-duration 29 \
      --transition-fps 60
  '';

in
{
  systemd.user.services.swww = {
    Unit = {
      Description = "A Solution to your Wayland Wallpaper Woes";
      Documentation = [ "man:swww-daeomn(1)" "man:swww(1)" ];

      PartOf = [ "sway-session.target" ];
      Requires = [ "sway-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.swww}/bin/swww-daemon";
      Restart = "always";
    };

    Install = {
      WantedBy = [ "sway-session.target" ];
    };
  };

  systemd.user.services.bluemarble = {
    Unit = {
      Description = "Download latest full-disk image";
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${bluemarble}/bin/bluemarble";
    };
  };

  systemd.user.timers.bluemarble = {
    Unit = {
      Description = "Download latest full-disk image";

      Requires = [ "swww.service" ];
      After = [ "swww.service" ];
    };

    Timer = {
      OnCalendar = "*:0/15";
    };

    Install = {
      WantedBy = [ "sway-session.target" ];
    };
  };
}

