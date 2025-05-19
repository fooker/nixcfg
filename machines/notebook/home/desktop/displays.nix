{
  services.kanshi = {
    enable = true;

    settings = [
      {
        output.criteria = "eDP-1";
        output.mode = "2880x1800@60.001";
        output.scale = 1.4;
      }

      {
        profile.name = "mobile";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
        ];
      }

      {
        profile.name = "home";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "Eizo Nanao Corporation EV2750 0x045B2CE1";
            status = "enable";
            mode = "2560x1440@59.951";
            position = "0,0";
          }
          {
            criteria = "Eizo Nanao Corporation EV2750 0x048B5C9D";
            status = "enable";
            mode = "2560x1440@59.951";
            position = "2560,0";
          }
          {
            criteria = "Eizo Nanao Corporation EV2750 0x05299C1A";
            status = "enable";
            mode = "2560x1440@59.951";
            position = "5120,0";
          }
        ];
      }

      {
        profile.name = "work";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            mode = "2880x1800@60.001";
            scale = 1.4;
            position = "0,700";
          }
          {
            criteria = "Philips Consumer Electronics Company PHL 240B7QPJ AU11913001819";
            status = "enable";
            mode = "1920x1200@59.950";
            position = "2059,0";
          }
          {
            criteria = "Philips Consumer Electronics Company PHL 240B7QPJ AU11913002036";
            status = "enable";
            mode = "1920x1200@59.950";
            position = "3979,0";
          }
        ];
      }

      {
        profile.name = "space-monitor";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            mode = "2880x1800@60.001";
            position = "0,1080";
            scale = 1.4;
          }
          {
            criteria = "LG Electronics W2442 0x0005229E";
            status = "enable";
            mode = "1920x1080@59.934";
            position = "239,0";
          }
        ];
      }
    ];
  };
}

