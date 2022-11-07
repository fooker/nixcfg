with builtins;

let
  # Stolen from nixpkgs/lib
  mapAttrsToList = f: attrs:
    map (name: f name attrs.${name}) (attrNames attrs);

  timetable = {
    "janine" = {
      "08:00" = 17.5;
      "19:00" = 20.0;
    };
    "dustin" = {
      "08:00" = 17.5;
      "19:00" = 20.0;
    };

    "luke" = {
      "08:00" = 17.5;
      "15:30" = 20.0;
    };
    "ada" = {
      "08:00" = 17.5;
      "15:30" = 20.0;
    };

    "living" = {
      "15:30" = 20.0;
      "23:00" = 17.5;
    };
    "dining" = {
      "15:30" = 20.0;
      "23:00" = 17.5;
    };
  };
in

concatLists (mapAttrsToList
  (device: mapAttrsToList
    (time: temperature: {
      alias = "Set thermostat temperature for ${device} at ${time} to ${toString temperature}";
      trigger = [{
        platform = "time";
        at = time;
      }];
      action = [{
        service = "climate.set_temperature";
        target.entity_id = "climate.heater_${device}";
        data = {
          hvac_mode = "auto";
          inherit temperature;
        };
      }];
    }))
  timetable)
