{ pkgs, ... }:

let
  parsecgamingPkg = pkgs.stdenv.mkDerivation {
    name = "parsecgaming-pkg";
    src = pkgs.fetchurl {
      url = "https://builds.parsecgaming.com/package/parsec-linux.deb";
      hash = "sha256-wwBy86TdrHaH9ia40yh24yd5G84WTXREihR+9I6o6uU=";
    };
    phases = [ "buildPhase" ];
    nativeBuildInputs = with pkgs; [ dpkg ];
    buildPhase = ''
      mkdir $out
      dpkg-deb -x $src $out
      chmod 755 $out
      mv $out/usr/* $out
      rmdir $out/usr
    '';
  };
  parsecgaming = pkgs.buildFHSUserEnv {
    name = "parsecgaming";
    targetPkgs = pkgs: with pkgs; [
      alsaLib
      cups
      dbus
      parsecgamingPkg
      fontconfig
      freetype
      libGL
      libpulseaudio
      libsamplerate
      udev
      libva
      libxkbcommon
      ffmpeg_4
      nas
      stdenv.cc.cc.lib
      vulkan-loader
      openssl

      xorg.libX11
      xorg.libXScrnSaver
      xorg.libXcursor
      xorg.libXext
      xorg.libXi
      xorg.libXinerama
      xorg.libXrandr
      xorg.libXrender
      xorg.libXxf86vm
      xorg.libxcb
    ];
    runScript = "/usr/bin/parsecd";

    meta = {
      description = "Parsec Gaming Daemon";
      homepage = https://www.parsecgaming.com/;
    };
  };

in
{
  nixpkgs.overlays = [
    (_: _: {
      inherit parsecgaming;
    })
  ];
}
