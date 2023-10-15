{ pkgs, ... }:

let
  sway-run = pkgs.writeShellScript "sway-run" ''
    source ~/.nix-profile/etc/profile.d/hm-session-vars.sh

    systemd-run \
      --user \
      --scope \
      --collect \
      --quiet \
      --unit=sway \
      systemd-cat \
        --identifier=sway \
        ${pkgs.sway}/bin/sway \
        $@
  '';
in
{
  services.greetd = {
    enable = true;

    settings = rec {
      default_session = {
        command = sway-run;
        user = "fooker";
      };

      initial_session = default_session;
    };
  };
}
