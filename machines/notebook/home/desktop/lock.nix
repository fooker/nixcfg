{ pkgs, ... }:

{
  services.swayidle = {
    enable = true;
    events = [
      { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      { event = "after-resume"; command = "${pkgs.sway}/bin/swaymsg output * dpms on"; }
    ];
    timeouts = [
      { timeout = 300; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      { timeout = 600; command = "${pkgs.sway}/bin/swaymsg output * dpms off"; }
    ];
  };

  programs.swaylock = {
    enable = true;
    settings = {
      image = "/home/fooker/docs/lock.png";
      indicator-idle-visible = false;
      ignore-empty-password = true;
      show-failed-attempts = true;
    };
  };
}
