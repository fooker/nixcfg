{ pkgs, nodes, ... }:

let
  rapz = pkgs.writeText "liquidsoap-rapz.liq" ''
    log.stdout := true

    pl = crossfade(
      duration = 2.0,
      normalize(
        playlist(
          reload = 60,
          "/mnt/media/music/rapz.txt")))

    output.icecast(%vorbis,
      host = "${toString nodes.zitadelle-north.config.peering.domains.dn42.ipv4.address}",
      port = ${toString nodes.zitadelle-north.config.services.icecast.listen.port},
      mount = "/rapz.ogg",
      password = "password",
      mksafe(pl))

    output.icecast(%vorbis,
      host = "${toString nodes.zitadelle-south.config.peering.domains.dn42.ipv4.address}",
      port = ${toString nodes.zitadelle-south.config.services.icecast.listen.port},
      mount = "/rapz.ogg",
      password = "password",
      mksafe(pl))
  '';

in
{
  services.liquidsoap.streams = {
    inherit rapz;
  };
}

