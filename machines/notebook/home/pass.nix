{ pkgs, ... }:

let
  path = "/home/fooker/docs/passwords";
in
{
  programs.password-store = {
    enable = true;

    package = pkgs.pass-wayland.withExtensions (exts: [
      exts.pass-checkup
      exts.pass-otp
      exts.pass-import
      exts.pass-update
    ]);

    settings = {
      PASSWORD_STORE_DIR = path;
    };
  };

  services.git-sync = {
    enable = true;
    repositories = {
      "password" = {
        inherit path;
        uri = "git+ssh://git@git.home.open-desk.net:fooker/pass.git";
      };
    };
  };

  programs.rbw = {
    enable = true;
    settings = {
      base_url = "https://vault.open-desk.net";
      email = "fooker@lab.sh";
      pinentry = pkgs.pinentry-gnome3;
    };
  };
}
