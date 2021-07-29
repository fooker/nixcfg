{
  programs.mosh.enable = true;

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      mosh = between [ "established" ] [ "drop" ] ''
        udp dport 60000-60010
        accept
      '';
    };
  };
}
