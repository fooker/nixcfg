let
  sources = import ../../nix/sources.nix;
in
{
  nixpkgs.overlays = [
    (_: super: {
      ate = super.callPackage sources.ate { };
    })
  ];

  nixpkgs.config.ate = {
    options = {
      BACKGROUND_COLOR = "#000000";
    };
    keybindings = {
      INCREMENT_FONT = "control+plus";
      DECREMENT_FONT = "control+minus";
    };
  };
}
