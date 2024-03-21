{ pkgs, ... }:

let
  passmenu = pkgs.writeShellScript "passmenu" ''
    shopt -s nullglob globstar

    typeit=0
    if [[ $1 == "--type" ]]; then
      typeit=1
      shift
    fi

    prefix=''${PASSWORD_STORE_DIR-~/.password-store}

    password_files=( "$prefix"/**/*.gpg )
    password_files=( "''${password_files[@]#"$prefix"/}" )
    password_files=( "''${password_files[@]%.gpg}" )

    password="$(printf '%s\n' "''${password_files[@]}" | "${pkgs.bemenu}/bin/bemenu" "$@")"

    [[ -n "$password" ]] || exit

    if [[ $typeit -eq 0 ]]; then
      ${pkgs.pass}/bin/pass show "$password" | { IFS= read -r pass; printf %s "$pass"; } | ${pkgs.wl-clipboard}/bin/wl-copy
    else
      ${pkgs.pass}/bin/pass show "$password" | { IFS= read -r pass; printf %s "$pass"; } | ${pkgs.wtype}/bin/wtype -
    fi
  '';

in
{
  wayland.windowManager.sway = {
    enable = true;

    systemd.enable = true;

    config = rec {
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

      window = {
        border = 2;
        titlebar = true;
      };

      workspaceAutoBackAndForth = true;

      input = {
        "*" = {
          "xkb_layout" = "de";
          "xkb_variant" = "nodeadkeys";
        };

        "2:10:TPPS\/2_Synaptics_TrackPoint" = {
          "accel_profile" = "adaptive";
          "pointer_accel" = "-0.6";
        };

        "type:pointer" = {
          "scroll_method" = "on_button_down";
          "scroll_button" = "274";
          "middle_emulation" = "enabled";
        };
      };

      keybindings = {
        # Floating windows and popups
        "${modifier}+d" = "focus mode_toggle";
        "${modifier}+Shift+d" = "floating toggle";

        # Window modes
        "${modifier}+a" = "layout tabbed";
        "${modifier}+s" = "layout toggle split";

        "${modifier}+f" = "fullscreen toggle";

        "${modifier}+h" = "split h";
        "${modifier}+v" = "split v";

        # Change and move focus
        "${modifier}+Left" = "focus left";
        "${modifier}+Right" = "focus right";
        "${modifier}+Up" = "focus up";
        "${modifier}+Down" = "focus down";
        "${modifier}+period" = "focus parent";

        "${modifier}+Shift+Left" = "move left";
        "${modifier}+Shift+Right" = "move right";
        "${modifier}+Shift+Up" = "move up";
        "${modifier}+Shift+Down" = "move down";

        # Switch and move workspace
        "${modifier}+0" = "workspace 0";
        "${modifier}+1" = "workspace 1";
        "${modifier}+2" = "workspace 2";
        "${modifier}+3" = "workspace 3";
        "${modifier}+4" = "workspace 4";
        "${modifier}+5" = "workspace 5";
        "${modifier}+6" = "workspace 6";
        "${modifier}+7" = "workspace 7";
        "${modifier}+8" = "workspace 8";
        "${modifier}+9" = "workspace 9";

        "${modifier}+Shift+0" = "move container to workspace 0";
        "${modifier}+Shift+1" = "move container to workspace 1";
        "${modifier}+Shift+2" = "move container to workspace 2";
        "${modifier}+Shift+3" = "move container to workspace 3";
        "${modifier}+Shift+4" = "move container to workspace 4";
        "${modifier}+Shift+5" = "move container to workspace 5";
        "${modifier}+Shift+6" = "move container to workspace 6";
        "${modifier}+Shift+7" = "move container to workspace 7";
        "${modifier}+Shift+8" = "move container to workspace 8";
        "${modifier}+Shift+9" = "move container to workspace 9";

        # Close window
        "${modifier}+c" = "kill";

        # Reload and exit
        "${modifier}+w" = "reload";
        "${modifier}+Shift+w" = "restart";
        "${modifier}+Shift+q" = "exec ${pkgs.sway}/bin/swaynag -t warning -m 'Do you really want to exit?' -b 'Yes' '${pkgs.sway}/bin/swaymsg exit'";

        # Start some things
        "${modifier}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
        "${modifier}+Shift+Return" = "exec ${pkgs.alacritty}/bin/alacritty -e /run/wrappers/bin/sudo --shell";

        "${modifier}+space" = "exec ${pkgs.bemenu}/bin/bemenu-run -i -l 10 -p 'Run:' -fn 'monospace'";

        "${modifier}+p" = "exec ${passmenu} -i -l 10 -p 'Password:' -fn 'monospace'";
        "${modifier}+Shift+p" = "exec ${passmenu} --type -i -l 10 -p 'Password:' -fn 'monospace'";

        "${modifier}+Shift+x" = "exec ${pkgs.systemd}/bin/loginctl lock-session";
        "${modifier}+Shift+l" = "exec ${pkgs.systemd}/bin/loginctl lock-session";

        # Hot keys
        XF86MonBrightnessDown = "exec ${pkgs.light}/bin/light -U 10";
        XF86MonBrightnessUp = "exec ${pkgs.light}/bin/light -A 10";

        XF86AudioRaiseVolume = "exec ${pkgs.ponymix}/bin/ponymix increase 5";
        XF86AudioLowerVolume = "exec ${pkgs.ponymix}/bin/ponymix decrease 5";
        XF86AudioMute = "exec ${pkgs.ponymix}/bin/ponymix toggle";
      };

      terminal = "${pkgs.alacritty}/bin/alacritty";

      bars = [
        {
          command = "${pkgs.waybar}/bin/waybar";
        }
      ];
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

    extraSessionCommands = ''
      export WLR_DRM_NO_MODIFIERS=1

      export SDL_VIDEODRIVER=wayland
      export MOZ_ENABLE_WAYLAND=1

      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
  };

  gtk = {
    enable = true;

    gtk3.extraConfig = {
      gtk-cursor-blink = false;
    };
  };

  home = {
    packages = with pkgs; [
      gnome3.adwaita-icon-theme
      swaynotificationcenter
    ];
  };
}
