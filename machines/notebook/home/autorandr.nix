{ ... }:

{
  programs.autorandr = {
    enable = true;

    profiles = {
      "mobile" = {
        fingerprint = {
          "eDP-1" = "00ffffffffffff000e6f001400000000001d0104b51f117802b737ae5043b1280e52540000000101010101010101010101010101010140ce00a0f07028803020350035ae10000018000000000000000000000000000000000018000000fe0043534f542054330a2020202020000000fe004d4e453030314541312d310a20019302030f00e3058000e60605016a6a24000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a";
        };

        config = {
          "eDP-1" = {
            enable = true;
            mode = "2560x1440";
            position = "0x0";
          };
        };
      };

      "home" = {
        fingerprint = {
          "DP-2-2" = "00ffffffffffff0015c382269d5c8b041f1b0104a53c2278fa9325a9544d9e250c5054a10800a9408180d100b300a9c0810081c00101565e00a0a0a029503020350055502100001a000000100000000000000000000000000000000000fd003b3d1f5919000a202020202020000000fc004556323735300a202020202020010f020312f145100403020123091f078301000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c3";
          "DP-2-3" = "00ffffffffffff0015c382261a9c2905051c0104a53c2278fa9325a9544d9e250c5054a10800a9408180d100b300a9c0810081c00101565e00a0a0a029503020350055502100001a000000100000000000000000000000000000000000fd003b3d1f5919000a202020202020000000fc004556323735300a20202020202001cc020312f145100403020123091f078301000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c3";
          "eDP-1" = "00ffffffffffff000e6f001400000000001d0104b51f117802b737ae5043b1280e52540000000101010101010101010101010101010140ce00a0f07028803020350035ae10000018000000000000000000000000000000000018000000fe0043534f542054330a2020202020000000fe004d4e453030314541312d310a20019302030f00e3058000e60605016a6a24000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a";
          "DVI-I-1-1" = "00ffffffffffff0015c38426e12c5b04341d0103803c2278ea9325a9544d9e250c5054210800a9408180d100b300a9c0810081c00101565e00a0a0a029503020350055502100001a21390000a3a01c507808351055502100001c000000fd001d3d1f5919000a202020202020000000fc004556323735300a2020202020200146020321f149101f04131203110201230907078301000067030c0010000032e2006a283c80a070b023403020360055502100001a8c0ad08a20e02d10103e96005550210000188c0ad090204031200c405500555021000018011d00bc52d01e20b828554055502100001e011d007251d01e206e28550055502100001e000000009c";
        };

        config = {
          "eDP-1" = {
            enable = false;
          };
          "DVI-I-1-1" = {
            enable = true;
            mode = "2560x1440";
            position = "0x0";
          };
          "DP-2-2" = {
            enable = true;
            mode = "2560x1440";
            position = "2560x0";
          };
          "DP-2-3" = {
            enable = true;
            mode = "2560x1440";
            position = "5120x0";
          };
        };
      };

      "home-small" = {
        fingerprint = {
          "DP-2-2" = "00ffffffffffff0015c382269d5c8b041f1b0104a53c2278fa9325a9544d9e250c5054a10800a9408180d100b300a9c0810081c00101565e00a0a0a029503020350055502100001a000000100000000000000000000000000000000000fd003b3d1f5919000a202020202020000000fc004556323735300a202020202020010f020312f145100403020123091f078301000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c3";
          "DP-2-3" = "00ffffffffffff0015c382261a9c2905051c0104a53c2278fa9325a9544d9e250c5054a10800a9408180d100b300a9c0810081c00101565e00a0a0a029503020350055502100001a000000100000000000000000000000000000000000fd003b3d1f5919000a202020202020000000fc004556323735300a20202020202001cc020312f145100403020123091f078301000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c3";
          "eDP-1" = "00ffffffffffff000e6f001400000000001d0104b51f117802b737ae5043b1280e52540000000101010101010101010101010101010140ce00a0f07028803020350035ae10000018000000000000000000000000000000000018000000fe0043534f542054330a2020202020000000fe004d4e453030314541312d310a20019302030f00e3058000e60605016a6a24000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a";
        };

        config = {
          "eDP-1" = {
            enable = false;
          };
          "DP-2-2" = {
            enable = true;
            mode = "2560x1440";
            position = "0x0";
          };
          "DP-2-3" = {
            enable = true;
            mode = "2560x1440";
            position = "2560x0";
          };
        };
      };

      "home-thm" = {
        fingerprint = {
          "DP-2-2" = "00ffffffffffff0015c382269d5c8b041f1b0104a53c2278fa9325a9544d9e250c5054a10800a9408180d100b300a9c0810081c00101565e00a0a0a029503020350055502100001a000000100000000000000000000000000000000000fd003b3d1f5919000a202020202020000000fc004556323735300a202020202020010f020312f145100403020123091f078301000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c3";
          "DP-2-3" = "00ffffffffffff0015c382261a9c2905051c0104a53c2278fa9325a9544d9e250c5054a10800a9408180d100b300a9c0810081c00101565e00a0a0a029503020350055502100001a000000100000000000000000000000000000000000fd003b3d1f5919000a202020202020000000fc004556323735300a20202020202001cc020312f145100403020123091f078301000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c3";
          "eDP-1" = "00ffffffffffff000e6f001400000000001d0104b51f117802b737ae5043b1280e52540000000101010101010101010101010101010140ce00a0f07028803020350035ae10000018000000000000000000000000000000000018000000fe0043534f542054330a2020202020000000fe004d4e453030314541312d310a20019302030f00e3058000e60605016a6a24000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a";
          "DP-2-1" = "00ffffffffffff0015c38426e12c5b04341d0103803c2278ea9325a9544d9e250c5054a10800a9408180d100b300a9c0810081c00101565e00a0a0a029503020350055502100001a21390000a3a01c507808351055502100001c000000fd001d3d1f5919000a202020202020000000fc004556323735300a20202020202001c6020321f149101f04131203110201230907078301000067030c0010008032e2006a283c80a070b023403020360055502100001a8c0ad08a20e02d10103e96005550210000188c0ad090204031200c405500555021000018011d00bc52d01e20b828554055502100001e011d007251d01e206e28550055502100001e000000001c";
        };

        config = {
          "eDP-1" = {
            enable = false;
          };
          "DP-2-1" = {
            enable = true;
            mode = "2560x1440";
            rate = "29.94";
            position = "0x0";
          };
          "DP-2-2" = {
            enable = true;
            mode = "2560x1440";
            position = "2560x0";
          };
          "DP-2-3" = {
            enable = true;
            mode = "2560x1440";
            position = "5120x0";
          };
        };
      };

      "work" = {
        fingerprint = {
          "DP-2-2" = "00ffffffffffff0015c38226c42943020d1a0104a53c2278fa9325a9544d9e250c5054a10800a9408180d100b300a9c0810081c00101565e00a0a0a029503020350055502100001a000000100000000000000000000000000000000000fd003b3d1f5919000a202020202020000000fc004556323735300a2020202020200178020312f145100403020123091f078301000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c3";
          "DP-2-3" = "00ffffffffffff00410c00092d010000131d0104a53c22783a4455a9554d9d260f5054bfef00d1c0b30095008180814081c001010101565e00a0a0a029503020350055502100001e000000fd00324c1e631e010a202020202020000000fc0050484c20323732423751504a0a000000ff0041553531393139303030333031018902031ef14b0103051404131f12021190230907078301000065030c001000023a801871382d40582c450055502100001e011d007251d01e206e28550055502100001e8c0ad08a20e02d10103e96005550210000188c0ad090204031200c405500555021000018f03c00d051a0355060883a0055502100001c0000000000000077";
          "eDP-1" = "00ffffffffffff000e6f001400000000001d0104b51f117802b737ae5043b1280e52540000000101010101010101010101010101010140ce00a0f07028803020350035ae10000018000000000000000000000000000000000018000000fe0043534f542054330a2020202020000000fe004d4e453030314541312d310a20019302030f00e3058000e60605016a6a24000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a";
        };

        config = {
          "eDP-1" = {
            enable = false;
          };
          "DP-2-2" = {
            enable = true;
            mode = "2560x1440";
            position = "0x0";
          };
          "DP-2-3" = {
            enable = true;
            mode = "2560x1440";
            position = "2560x0";
          };
        };
      };

      "space-monitor" = {
        fingerprint = {
          "HDMI-2" = "00ffffffffffff001e6dcc569e2205000514010380351e780aaec5a2574a9c25125054210800b30081808140010101010101010101011a3680a070381f4030203500132b2100001a023a801871382d40582c4500132b2100001e000000fd00383d1e530f000a202020202020000000fc0057323434320a2020202020202001e2020321f14e900403011412051f101300000000230907078301000065030c001000023a801871382d40582c4500132b2100001e011d8018711c1620582c2500132b2100009e011d007251d01e206e285500132b2100001e8c0ad08a20e02d10103e9600132b210000180000000000000000000000000000000000000000000026";
          "eDP-1" = "00ffffffffffff000e6f001400000000001d0104b51f117802b737ae5043b1280e52540000000101010101010101010101010101010140ce00a0f07028803020350035ae10000018000000000000000000000000000000000018000000fe0043534f542054330a2020202020000000fe004d4e453030314541312d310a20019302030f00e3058000e60605016a6a24000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a";
        };

        config = {
          "eDP-1" = {
            enable = true;
            mode = "2560x1440";
            position = "0x1080";
          };
          "HDMI-2" = {
            enable = true;
            mode = "1920x1080";
            position = "0x0";
          };
        };
      };
    };
  };
}
