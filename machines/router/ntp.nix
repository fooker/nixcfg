{
  services.chrony = {
    enable = true;
  };

  firewall.rules = dag: with dag; {
    inet.filter.forward = {
      ntp = before [ "drop" ] ''
        meta iifname { mngt, priv, guest, iot }
        udp dport 123
        accept
      '';
    };
  };
}
