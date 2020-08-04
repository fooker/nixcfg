{ pkgs, sources, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      ate = pkgs.callPackage sources.ate {};
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
