{
  platform.rpi3 = true;

  hardware.deviceTree = {
    enable = true;
    overlays = [{
      name = "spi";
      dtsText = ''
        /dts-v1/;
        /plugin/;
        
        / {
          compatible = "raspberrypi,3-model-b", "brcm,bcm2837";
  
          fragment@0 {
            target = <&spi>;
            __overlay__ {
              pinctrl-names = "default";
              pinctrl-0 = <&spi0_gpio7>;

              status = "okay";

              spidev0: spidev@0{
                 compatible = "linux,spidev";
                 reg = <0>;
                 #address-cells = <1>;
                 #size-cells = <0>;
                 spi-max-frequency = <125000000>;
              };
            };
          };
        };
      '';
    }];
  };
}
