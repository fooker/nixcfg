{
  services.chrony = {
    enable = true;

    extraConfig = ''
      allow all
    '';
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      ntp = before [ "drop" ] ''
        meta iifname { mngt, priv, guest, iot }
        udp dport 123
        accept
      '';
    };
  };
}
