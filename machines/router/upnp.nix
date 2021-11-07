{ lib, pkgs, ... }:

let
  scriptBinEnv = lib.makeBinPath (with pkgs; [
    nftables
  ]);

  miniupnpd-nft = pkgs.miniupnpd.overrideAttrs (_: {
    makefile = "Makefile.linux_nft";

    buildInputs = with pkgs; [ libmnl libnftnl libuuid ];

    postFixup = ''
      for script in $out/etc/miniupnpd/nft_{delete_chain,flush,init,removeall}.sh
      do
        wrapProgram $script --set PATH '${scriptBinEnv}:$PATH'
      done
    '';
  });

  config = pkgs.writeText "miniupnpd.conf" ''
    ext_ifname=ppp0

    enable_natpmp=no
    enable_upnp=yes

    listening_ip=priv

    http_port=38199
  '';
in
{
  systemd.services.miniupnpd = {
    description = "MiniUPnP daemon";

    after = [ "network.target" ];
    bindsTo = [ "pppd-uplink.service" ];

    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "forking";
      ExecStart = "${miniupnpd-nft}/bin/miniupnpd -f ${config}";

      # ExecStartPre = "${miniupnpd-nft}/etc/miniupnpd/nft_init.sh";
      # ExecStopPost = "${miniupnpd-nft}/etc/miniupnpd/nft_removeall.sh";

      PIDFile = "/run/miniupnpd.pid";
    };
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      upnp = between [ "established" ] [ "drop" ] ''
        iifname "priv"
        udp dport 1900
        accept
      '';
      upnp-igd = between [ "established" ] [ "drop" ] ''
        iifname "priv"
        tcp dport 38199
        accept
      '';
    };
  };
}
