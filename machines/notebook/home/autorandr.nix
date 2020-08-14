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
    };
  };
}
