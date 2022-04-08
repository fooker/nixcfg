[
  {
    alias = "Turn on Origami Lights at sunset";
    trigger = [{
      platform = "sun";
      event = "sunset";
      offset = "-01:00:00";
    }];
    action = [{
      service = "light.turn_on";
      target = {
        entity_id = [
          "light.origami_light_left"
          "light.origami_light_right"
        ];
      };
      data = {
        brightness_pct = 50;
      };
    }];
  }
  {
    alias = "Turn down Origami Lights at midnight";
    trigger = [{
      platform = "time";
      at = "00:00:00";
    }];
    condition = [{
      condition = "state";
      entity_id = [
        "light.origami_light_left"
        "light.origami_light_right"
      ];
      state = "on";
    }];
    action = [{
      service = "light.turn_on";
      target = {
        entity_id = [
          "light.origami_light_left"
          "light.origami_light_right"
        ];
      };
      data = {
        brightness_pct = 20;
      };
    }];
  }
  {
    alias = "Turn off Origami Lights at sunrise";
    trigger = [{
      platform = "sun";
      event = "sunrise";
      offset = "+01:00:00";
    }];
    action = [{
      service = "light.turn_off";
      target = {
        entity_id = [
          "light.origami_light_left"
          "light.origami_light_right"
        ];
      };
    }];
  }
]
