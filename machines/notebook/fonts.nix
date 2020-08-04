{ config, lib, pkgs, ... }:

{
  fonts = {
    fontconfig = {
      enable = true;
      antialias = true;
      cache32Bit = true;
      defaultFonts = {
        monospace = [ "Hack 10.5" ];
      };
    };
    enableDefaultFonts = true;
    enableFontDir = true;
    fonts = with pkgs; [
      hack-font
      noto-fonts
      symbola
      anonymousPro
      arkpandora_ttf
      caladea
      carlito
      comfortaa
      comic-relief
      crimson
      dejavu_fonts
      google-fonts
      inconsolata
      iosevka
      liberationsansnarrow
      liberation_ttf
      libertine
      mononoki
      montserrat
      nerdfonts
      norwester-font
      opensans-ttf
      powerline-fonts
      roboto
      sampradaya
      source-code-pro
      source-sans-pro
      source-serif-pro
      tai-ahom
      tempora_lgc
      terminus_font
      theano
      ubuntu_font_family
      font-awesome_4
      font-awesome
    ];
  };
}
