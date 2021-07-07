{
  systemd.network = {
    enable = true;

    links = {
      "00-ext" = {
        matchConfig = {
          MACAddress = "52:54:5a:81:b4:b2";
        };
        linkConfig = {
          Name = "ext";
        };
      };
    };

    networks = {
      "30-ext" = {
        name = "ext";
        address = [
          "37.120.172.177/22"
          "2a03:4000:6:701d::/64"
        ];
        gateway = [ "37.120.172.1" ];
        dns = [ "1.0.0.1" "1.1.1.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
      };
    };
  };
}
