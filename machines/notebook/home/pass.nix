{ pkgs, config, ... }:

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
        uri = "git+ssh://gitea@git.home.open-desk.net:fooker/pass.git";
      };
    };
  };

  programs.browserpass = {
    enable = true;
    browsers = [ "firefox" ];
  };
}
