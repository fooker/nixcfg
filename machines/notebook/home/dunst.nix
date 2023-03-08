{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        font = "Hack 11";

        markup = "full";
        format = "<b>%s %p</b>\\n%b";

        sort = true;
        indicate_hidden = true;

        alignment = "left";

        idle_threshold = 0;

        separator_height = 2;
        separator_color = "frame";

        padding = 8;
        horizontal_padding = 8;

        word_wrap = true;
        ignore_newline = false;

        geometry = "400x5-30+20";
        shrink = false;

        icon_position = "left";
        max_icon_size = 64;
      };

      frame = {
        width = 0;
        color = "#4c4c4c";
      };

      urgency_low = {
        background = "#4c4c4c";
        foreground = "#00beff";

        timeout = 10;
      };

      urgency_normal = {
        background = "#4c4c4c";
        foreground = "#beff00";

        timeout = 20;
      };

      urgency_critical = {
        background = "#4c4c4c";
        foreground = "#ffbe00";

        timeout = 0;
      };
    };
  };
}
