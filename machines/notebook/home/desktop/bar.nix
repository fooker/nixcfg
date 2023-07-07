{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "bottom";
        height = 30;

        modules-left = [
          "sway/workspaces"
        ];

        modules-center = [
        ];

        modules-right = [
          "idle_inhibitor"
          "pulseaudio"
          "cpu"
          "memory"
          "temperatur"
          "network#wl"
          "network#en"
          "battery"
          "tray"
          "clock"
        ];

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{icon}";
          format-icons = {
            "0" = "";
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "urgent" = "";
            "focused" = "";
          };
        };

        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = "󰝟";
          format-icons = {
            "headphone" = "󰋋";
            "default" = [ "" "󰕾" ];
          };
        };

        "cpu" = {
          format = " {usage}% [{max_frequency}]  {load}";
        };

        "memory" = {
          format = " {used}% 󰿢 {swapUsed}%";
        };

        "temperatur" = {
          format = " {temperatureC}°C";
        };

        "network#wl" = {
          interface = "wl";
          interval = 5;
          format = " {essid} {signalStrength} ({frequency})";
          format-disconnected = "";
        };

        "network#en" = {
          interface = "en";
          interval = 5;
          format = "󱂇 {ipaddr}/{cidr}";
          format-disconnected = "󱂇";
        };

        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}% [{time}]";
          format-time = "{H}:{M}";
          format-icons = [ "" "" "" "" "" ];
        };

        "tray" = {
          icon-size = 20;
          spacing = 5;
        };

        "clock" = {
          interval = 1;
          format = " {:%Y-%m-%d %H:%M:%S}";
        };
      };
    };
  };
}
