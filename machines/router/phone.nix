{ pkgs, config, lib, network, device, ... }:

with lib;

let
  firmware = rec {
    hashes = {
      "D713" = "sha256-XznfEjOYVgk+klmil8Axdfm8DURR4+Aa+7mVUWaslYo=";
    };

    version = "10.1.175.10";

    bin = model: pkgs.fetchurl {
      url = "https://downloads.snom.com/fw/${version}/bin/snom${model}-${version}-SIP-r.bin";
      hash = hashes.${model};
    };
  };

  ssiSecret = name: "<!--# include file=\"secrets/${name}\" -->";

  phones = [
    rec {
      name = "phone";
      model = "D713";
      inherit (network.devices."phone".interfaces."mngt") mac;
      config = {
        phone-settings = {
          setting_server = "https://snom.home.open-desk.net/snom${model}-${mac}.xml";
          np_config = "off";

          language = "Deutsch";
          timezone = "GER+1";
          tone_scheme = "GER";

          #update_policy = "auto_update";
          update_policy = "settings_only";
          firmware = "https://snom.home.open-desk.net/firmware/snom${model}.bin";

          prov_polling_enabled = "on";
          prov_polling_mode = "rel";
          prov_polling_period = "60";

          user_active."1" = "on";
          user_realname."1" = "Zuhause";
          user_name."1" = ssiSecret "phone/sip/user";
          user_host."1" = ssiSecret "phone/sip/host";
          user_pass."1" = ssiSecret "phone/sip/pass";

          stun_server."1" = "stun.1und1.de";
          stun_binding_interval."1" = "30";
          keepalive_interval."1" = "30";

          admin_mode = "off";
          admin_mode_password = ssiSecret "phone/admin/pass";

          http_user = ssiSecret "phone/http/user";
          http_pass = ssiSecret "phone/http/pass";

          ui_theme = "Colorful";

          ring_sound = "Ringer9";

          dkey_dnd = "keyevent F_NONE";

          dialnumber_us_format = "off";
          date_us_format = "off";
          time_24_format = "on";
          show_clock = "on";

          backlight = "15";
          backlight_idle = "3";
          dim_timer = "30";
        };
      };
    }
  ];

  xml = { name, config, ... }: pkgs.runCommand "snom-config-${name}.xml"
    {
      buildInputs = [ pkgs.libxslt ];

      stylesheet = builtins.toFile "snom-config.xslt" ''
        <?xml version='1.0' encoding='UTF-8'?>
        <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='1.0'>

        <xsl:output method="xml" indent="yes" version="1.0" encoding="UTF-8" standalone="yes" />

        <xsl:template match='/'>
          <settings>
            <phone-settings>
              <xsl:for-each select="/expr/attrs/attr[@name = 'phone-settings']/attrs/attr">
                <xsl:if test="string/@value">
                  <xsl:element name="{@name}">
                    <xsl:attribute name="perm">R</xsl:attribute>
                    <xsl:value-of select="string/@value" disable-output-escaping="yes" />
                  </xsl:element>
                </xsl:if>

                <xsl:for-each select="attrs/attr">
                  <xsl:element name="{../../@name}">
                    <xsl:attribute name="perm">R</xsl:attribute>

                    <xsl:attribute name="idx">
                      <xsl:value-of select="@name" />
                    </xsl:attribute>

                    <xsl:value-of select="string/@value" disable-output-escaping="yes" />
                  </xsl:element>
                </xsl:for-each>
              </xsl:for-each>
            </phone-settings>
          </settings>
        </xsl:template>
        </xsl:stylesheet>
      '';

      config = builtins.toFile "snom-config-${name}.nixml" (builtins.toXML config);
    } ''
    xsltproc "$stylesheet" "$config" > "$out"
  '';

  root = pkgs.linkFarm "snom" (concatLists [
    (map
      (model: {
        name = "firmware/snom${model}.bin";
        path = firmware.bin model;
      })
      (attrNames (groupBy
        ({ model, ... }: model)
        phones)))

    (map
      ({ model, mac, ... }@phone: {
        name = "snom${model}-${pipe mac [ toUpper (replaceStrings [ ":" ] [ "" ]) ]}.htm";
        path = xml phone;
      })
      phones)

    (map
      (name: {
        name = "secrets/${name}";
        inherit (config.sops.secrets.${name}) path;
      })
      [
        "phone/sip/user"
        "phone/sip/host"
        "phone/sip/pass"
        "phone/admin/pass"
        "phone/http/user"
        "phone/http/pass"
      ])
  ]);

in
{
  web.apps."snom" = {
    domains = [ "snom.home.open-desk.net" ];

    inherit root;

    config = {
      extraConfig = ''
        allow 192.168.254.0/24;
        deny all;
      '';

      locations."/".extraConfig = ''
        ssi on;
        ssi_types "*" * application/xml text/xml;
      '';

      locations."/secrets".extraConfig = ''
        deny all;
      '';
    };
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      webapp-ppp = before [ "webapp" ] [
        "meta iifname ppp0 tcp dport { 80, 443 } drop"
        "meta iifname ppp0 udp dport { 80, 443 } drop"
      ];
    };
  };

  sops.secrets."phone/sip/user" = { owner = "nginx"; };
  sops.secrets."phone/sip/host" = { owner = "nginx"; };
  sops.secrets."phone/sip/pass" = { owner = "nginx"; };

  sops.secrets."phone/admin/pass" = { owner = "nginx"; };

  sops.secrets."phone/http/user" = { owner = "nginx"; };
  sops.secrets."phone/http/pass" = { owner = "nginx"; };
}

