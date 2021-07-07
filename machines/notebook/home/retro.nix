{ lib, pkgs, ... }:

with lib;

let
  romsPath = name: "~/roms/${ name }";

in
{
  home.packages = with pkgs; [
    emulationstation
  ];

  home.file.".emulationstation/es_systems.cfg".text =
    let

      mkRetroarchSystem = { name, desc, extensions, core, platform, theme }: (mkSystem {
        inherit name desc extensions platform theme;
        command = "${ pkgs.retroarch }/bin/retroarch --fullscreen -L ${ pkgs.libretro."${ core }" }/lib/retroarch/cores/${ core }_libretro.so %ROM%";
      });

      mkSystem = { name, desc, extensions, command, platform, theme }: {
        inherit name desc extensions command platform theme;
      };

      systems = [
        (mkRetroarchSystem {
          name = "nes";
          desc = "Nintendo Entertainment System";
          extensions = [ ".nes" ".NES" ];
          core = "fceumm";
          platform = "nes";
          theme = "nes";
        })

        (mkRetroarchSystem {
          name = "snes";
          desc = "Super Nintendo Entertainment System";
          extensions = [ ".smc" ".sfc" ".fig" ".bin" ".zip" ];
          core = "snes9x";
          platform = "snes";
          theme = "snes";
        })
      ];
    in
    ''
      <systemList>
        ${ concatMapStringsSep "\n" (system: with system; ''
          <system>
            <name>${ name }</name>
            <fullname>${ desc }</fullname>
            <path>${ romsPath name }</path>
            <extension>${ concatStringsSep " " extensions }</extension>
            <command>${ command }</command>
            <platform>${ platform }</platform>
            <theme>${ theme }</theme>
          </system>
        '') systems }
      </systemList>
    '';
}
