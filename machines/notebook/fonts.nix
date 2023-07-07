{ pkgs, inputs, ... }:

let
  berkeley-mono-nerd-font = pkgs.callPackage "${inputs.private}/berkeley-mono-nerd-font/default.nix" { };
in
{
  fonts = {
    fontconfig = {
      enable = true;
      antialias = true;
      cache32Bit = true;
      defaultFonts = {
        monospace = [ "BerkeleyMono Nerd Font" ];
      };
    };

    fontDir.enable = true;

    enableDefaultFonts = true;
    fonts = with pkgs; [
      berkeley-mono-nerd-font

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
      inconsolata
      iosevka
      liberation-sans-narrow
      liberation_ttf
      libertine
      mononoki
      montserrat
      nerdfonts
      norwester-font
      open-sans
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
