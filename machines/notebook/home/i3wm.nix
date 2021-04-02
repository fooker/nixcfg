{ pkgs, ... }:

let
  i3status-rust-config = pkgs.writeText "i3status-rs.toml" ''
    theme = "slick"
    icons = "awesome"

    [[block]]
    block = "sound"

    [[block]]
    block = "cpu"
    interval = 1
    format = "{utilization} [{frequency}] "

    [[block]]
    block = "load"
    interval = 5
    format = "{1m}"

    [[block]]
    block = "memory"
    display_type = "memory"
    format_mem = "{Mup}%"
    format_swap = "{SUp}%"

    [[block]]
    block = "temperature"
    collapsed = false
    interval = 5
    format = "{max}°"    

    [[block]]
    block = "net"
    device = "wl"
    ssid = true
    signal_strength = true
    bitrate = true
    ip = true
    speed_up = true
    speed_down = true
    interval = 5

    [[block]]
    block = "net"
    device = "en"
    ssid = true
    ip = true
    speed_up = true
    speed_down = true
    interval = 5

    [[block]]
    block = "battery"
    driver = "upower"
    format = "{percentage}% [{time}]"

    [[block]]
    block = "time"
    interval = 1
    format = "%F %a %T"
  '';

  # wallpaper = builtins.fetchurl {
  #   name = "wallpaper.jpg";
  #   url = "https://w.wallhaven.cc/full/2e/wallhaven-2eqezx.jpg";
  #   sha256 = "1zc079sx3kad497wc1h5cznpml91gln1vkngk6m9izd0idw09s1r";
  # };

  # wallpaper = builtins.fetchurl {
  #   name = "wallpaper.jpg";
  #   url = "https://w.wallhaven.cc/full/49/wallhaven-49kdvw.png";
  #   sha256 = "0ybr2xk65x2vy0c2ahg2nsn77c9552plxrys09x35f5apy7wfz4q";
  # };

  # wallpaper = builtins.fetchurl {
  #   name = "wallpaper.jpg";
  #   url = "https://w.wallhaven.cc/full/4l/wallhaven-4l3okl.jpg";
  #   sha256 = "1kvrwjr658sjxhw5w257bvnvcn5h321p76rnjpcjh3y250ndqcdw";
  # };

  # wallpaper = builtins.fetchurl {
  #   name = "wallpaper.jpg";
  #   url = "http://getwallpapers.com/wallpaper/full/6/d/d/853739-download-starry-night-backgrounds-1920x1080.jpg";
  #   sha256 = "1kilpz8l0np8zdjpqq850xha1nmy6gh2nhrvmjxkd83632askqvd";
  # };

  wallpaper = builtins.fetchurl {
    name = "wallpaper.jpg";
    url = "https://w.wallhaven.cc/full/ne/wallhaven-ne622l.jpg";
    sha256 = "0py9qixisbvjr811fj2a8z7kpn5lqa3s4w7ax7wdavz1f4mnw3w4";
  };

in {
  xsession = {
    enable = true;

    scriptPath = ".xinitrc";

    windowManager.i3 = {
      enable = true;

      config = {
        modifier = "Mod4";

        floating = {
          modifier = "Mod4";
          border = 2;
          titlebar = true;
        };

        focus = {
          followMouse = true;
          mouseWarping = true;
          newWindow = "none";
        };

        fonts = [ "Hack 10.5" ];

        window = {
          border = 2;
          titlebar = true;
        };

        workspaceAutoBackAndForth = true;

        terminal = "${pkgs.ate}/bin/ate";

        keybindings =
          let
            mod = "Mod4";
          in with pkgs; {
            # Floating windows and popups
            "${mod}+d" = "focus mode_toggle";
            "${mod}+Shift+d" = "floating toggle";

            # Window modes
            "${mod}+a" = "layout tabbed";
            "${mod}+s" = "layout toggle split";

            "${mod}+f" = "fullscreen toggle";

            "${mod}+h" = "split h";
            "${mod}+v" = "split v";

            # Change and move focus
            "${mod}+Left" = "focus left";
            "${mod}+Right" = "focus right";
            "${mod}+Up" = "focus up";
            "${mod}+Down" = "focus down";
            "${mod}+period" = "focus parent";

            "${mod}+Shift+Left" = "move left";
            "${mod}+Shift+Right" = "move right";
            "${mod}+Shift+Up" = "move up";
            "${mod}+Shift+Down" = "move down";

            # Switch and move workspace
            "${mod}+0" = "workspace 0";
            "${mod}+1" = "workspace 1";
            "${mod}+2" = "workspace 2";
            "${mod}+3" = "workspace 3";
            "${mod}+4" = "workspace 4";
            "${mod}+5" = "workspace 5";
            "${mod}+6" = "workspace 6";
            "${mod}+7" = "workspace 7";
            "${mod}+8" = "workspace 8";
            "${mod}+9" = "workspace 9";

            "${mod}+Shift+0" = "move container to workspace 0";
            "${mod}+Shift+1" = "move container to workspace 1";
            "${mod}+Shift+2" = "move container to workspace 2";
            "${mod}+Shift+3" = "move container to workspace 3";
            "${mod}+Shift+4" = "move container to workspace 4";
            "${mod}+Shift+5" = "move container to workspace 5";
            "${mod}+Shift+6" = "move container to workspace 6";
            "${mod}+Shift+7" = "move container to workspace 7";
            "${mod}+Shift+8" = "move container to workspace 8";
            "${mod}+Shift+9" = "move container to workspace 9";

            # Close window
            "${mod}+c" = "kill";

             # Reload and exit
            "${mod}+w" = "reload";
            "${mod}+Shift+w" = "restart";
            "${mod}+Shift+q" = "exec ${pkgs.i3}/bin/i3-nagbar -t warning -m 'Do you really want to exit?' -b 'Yes' '${pkgs.i3}/bin/i3-msg exit'";

             # Start some things
            "${mod}+Return" = "exec ${pkgs.ate}/bin/ate";
            "${mod}+Shift+Return" = "exec ${ate}/bin/ate /run/wrappers/bin/sudo --shell";

            "${mod}+space" = "exec ${pkgs.dmenu}/bin/dmenu_run -i -l 10 -p 'Run:' -fn 'Hack-10.5'";

            "${mod}+p" = "exec ${pkgs.pass}/bin/passmenu -i -l 10 -p 'Password:' -fn 'Hack-10.5'";
            "${mod}+Shift+p" = "exec ${pkgs.pass}/bin/passmenu --type -i -l 10 -p 'Password:' -fn 'Hack-10.5'";

            "${mod}+Shift+x" = "exec ${pkgs.systemd}/bin/loginctl lock-session";
            "${mod}+Shift+l" = "exec ${pkgs.systemd}/bin/loginctl lock-session";

            # Hot keys
            XF86MonBrightnessDown = "exec ${brightnessctl}/bin/brightnessctl -q s 5%-";
            XF86MonBrightnessUp = "exec ${brightnessctl}/bin/brightnessctl -q s 5%+";

            XF86AudioRaiseVolume = "exec ${ponymix}/bin/ponymix increase 5";
            XF86AudioLowerVolume = "exec ${ponymix}/bin/ponymix decrease 5";
            XF86AudioMute = "exec ${ponymix}/bin/ponymix toggle";

            XF86AudioPlay = "exec ${playerctl}/bin/playerctl play-pause";
            XF86AudioPause = "exec ${playerctl}/bin/playerctl pause";
            XF86AudioNext = "exec ${playerctl}/bin/playerctl next";
            XF86AudioPrev = "exec ${playerctl}/bin/playerctl previous";

            XF86Display = "exec ${xorg.xrandr}/bin/xrandr --auto";
          };

        bars = [
          {
            workspaceButtons = false;

            statusCommand = "${pkgs.master.i3status-rust}/bin/i3status-rs ${i3status-rust-config}";
            
            trayOutput = "*";

            fonts = [
              "FontAwesome" "Hack 10.5"
            ];

            colors = {
              background = "#00000000";
            };
          }
        ];

        colors = {
          focused         = { border = "#285577"; background = "#285577"; text = "#ffffff"; indicator = "#2e9ef4"; childBorder = "#285577"; };
          focusedInactive = { border = "#5f676a"; background = "#5f676a"; text = "#ffffff"; indicator = "#484e50"; childBorder = "#5f676a"; };
          unfocused       = { border = "#333333"; background = "#222222"; text = "#888888"; indicator = "#292d2e"; childBorder = "#222222"; };
          urgent          = { border = "#2f343a"; background = "#900000"; text = "#ffffff"; indicator = "#900000"; childBorder = "#900000"; };
          placeholder     = { border = "#000000"; background = "#0c0c0c"; text = "#ffffff"; indicator = "#000000"; childBorder = "#0c0c0c"; };
        };
      };

      extraConfig = ''
        workspace 0 output DP-2-3
        workspace 1 output DP-2-3
        workspace 2 output DP-2-3
        workspace 3 output DP-2-2
        workspace 4 output DP-2-2
        workspace 5 output DP-2-2
        workspace 6 output DP-2-2
      '';
    };
  };

  # xsession.pointerCursor = {
  #   package = pkgs.	gnome3.adwaita-icon-theme;
  #   name = "Adwaita";
  # };

  # xresources.properties = {
  #   "Xft.dpi" = 144;
  #   "Xft.autohint" = 0;
  #   "Xft.lcdfilter" = "lcddefault";
  #   "Xft.hintstyle" = "hintfull";
  #   "Xft.hinting" = 1;
  #   "Xft.antialias" = 1;
  #   "Xft.rgba" = "rgb";
  # };

  gtk = {
    enable = true;
  };

  home.packages = with pkgs; [
    gnome3.adwaita-icon-theme
  ];

  services.screen-locker = {
    enable = true;
    enableDetectSleep = true;
    inactiveInterval = 10;
    lockCmd = "${pkgs.i3lock}/bin/i3lock --nofork --color=000000 --ignore-empty-password --show-failed-attempts";
  };
}
