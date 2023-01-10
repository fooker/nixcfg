{ ... }:

[
  {
    alias = "Origami Lights: Turn on at sunset";
    trigger = [{
      platform = "sun";
      event = "sunset";
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
        brightness_pct = 21;
      };
    }];
  }
  {
    alias = "Origami Lights: Turn down (1)";
    trigger = [{
      platform = "time";
      at = "21:30:00";
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
        brightness_pct = 14;
      };
    }];
  }
  {
    alias = "Origami Lights: Turn down (2)";
    trigger = [{
      platform = "time";
      at = "22:30:00";
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
        brightness_pct = 7;
      };
    }];
  }
  {
    alias = "Origami Lights: Turn off at sunrise";
    trigger = [{
      platform = "sun";
      event = "sunrise";
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
