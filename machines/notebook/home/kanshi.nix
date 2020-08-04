{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kanshi
  ];

  xdg.configFile."kanshi/config".text = ''
    {
      output eDP-1 enable mode 3840x2160 scale 2
    }
    {
      output eDP-1 disable
      output "Eizo Nanao Corporation EV2750 0x0000DF9D" enable mode 2560x1440 scale 1 position 0,0
      output "Eizo Nanao Corporation EV2750 0x0000BD1A" enable mode 2560x1440 scale 1 position 2560,0
    }
  '';
}