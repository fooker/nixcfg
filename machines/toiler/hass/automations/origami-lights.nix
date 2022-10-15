[
  {
    alias = "Turn on Origami Lights at sunset";
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
    alias = "Turn down Origami Lights (1)";
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
    alias = "Turn down Origami Lights (2)";
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
    alias = "Turn off Origami Lights at sunrise";
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
