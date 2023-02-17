{ lib, ... }:

with lib;

let
  timetable = {
    "janine" = {
      "08:00" = 17.5;
      "19:00" = 19.0;
    };
    "dustin" = {
      "08:00" = 17.5;
      "19:00" = 19.5;
    };

    "luke" = {
      "08:00" = 17.5;
      "15:30" = 19.5;
    };
    "ada" = {
      "08:00" = 17.5;
      "15:30" = 19.5;
    };

    "living" = {
      "15:30" = 19.0;
      "23:00" = 16.0;
    };
    "dining" = {
      "15:30" = 19.0;
      "23:00" = 16.0;
    };
    "stairs" = {
      "15:30" = 19.0;
      "23:00" = 16.0;
    };

    "nerding" = {
      "09:00" = 19.0;
      "19:00" = 19.0;
      "02:00" = 16.0;
    };
  };
in

concatLists (mapAttrsToList
  (device: mapAttrsToList
    (time: temperature: {
      alias = "Thermostat: Set temperature for ${device} at ${time} to ${toString temperature}";
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