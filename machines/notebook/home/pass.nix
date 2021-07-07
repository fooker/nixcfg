{ pkgs, ... }:

{
  programs.password-store = {
    enable = true;

    package = pkgs.pass-wayland.withExtensions (exts: [
      exts.pass-audit
      exts.pass-checkup
      exts.pass-otp
      exts.pass-import
      exts.pass-update
    ]);

    settings = {
      PASSWORD_STORE_DIR = "$HOME/docs/passwords";
    };
  };

  services.password-store-sync = {
    enable = true;
  };

  programs.browserpass = {
    enable = true;
    browsers = [ "firefox" ];
  };
}
