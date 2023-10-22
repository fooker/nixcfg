{
  services.kanshi = {
    enable = true;

    profiles = {
      "mobile" = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            mode = "2880x1800@60.001";
            scale = 1.4;
          }
        ];
      };

      "home" = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "Eizo Nanao Corporation EV2750 0x00007FE1";
            status = "enable";
            mode = "2560x1440@59.951";
            position = "0,0";
          }
          {
            criteria = "Eizo Nanao Corporation EV2750 0x0000DF9D";
            status = "enable";
            mode = "2560x1440@59.951";
            position = "2560,0";
          }
          {
            criteria = "Eizo Nanao Corporation EV2750 0x0000BD1A";
            status = "enable";
            mode = "2560x1440@59.951";
            position = "5120,0";
          }
        ];
      };

      "work" = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "Eizo Nanao Corporation EV2750 0x00006BC4";
            status = "enable";
            mode = "2560x1440@59.951";
            position = "0,0";
          }
          {
            criteria = "Philips Consumer Electronics Company PHL 272B7QPJ AU51919000301";
            status = "enable";
            mode = "2560x1440@59.951";
            position = "2560,0";
          }
        ];
      };

      "space-monitor" = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            mode = "2880x1800@60.001";
            position = "0,1080";
            scale = 1.4;
          }
          {
            criteria = "LG Electronics W2442 0x0000279E";
            status = "enable";
            mode = "1920x1080@59.934";
            position = "239,0";
          }
        ];
      };
    };
  };
}
