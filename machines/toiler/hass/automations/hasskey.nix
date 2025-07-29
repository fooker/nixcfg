let
  mkAutomation = { alias, device, key, actions }: {
    alias = "Dumbpad - ${alias}";

    triggers = [{
      trigger = "event";
      event_type = "hasskey";
      event_data = {
        inherit device;
        key = "KEY_${key}";
        value = "DOWN";
      };
    }];

    inherit actions;
  };

  mkMediaPlayerAction = device: action: data: {
    service = "media_player.${action}";

    target.entity_id = "media_player.${device}";

    inherit data;
  };

in
[
  (mkAutomation {
    alias = "On Air - Free";
    device = "dumbpad";
    key = "A";
    actions = [{
      action = "select.select_option";
      target.entity_id = "select.wled_preset_2";
      data.option = "Free";
    }];
  })
  (mkAutomation {
    alias = "On Air - Warn";
    device = "dumbpad";
    key = "B";
    actions = [{
      action = "select.select_option";
      target.entity_id = "select.wled_preset_2";
      data.option = "Warn";
    }];
  })
  (mkAutomation {
    alias = "On Air - Busy";
    device = "dumbpad";
    key = "C";
    actions = [{
      action = "select.select_option";
      target.entity_id = "select.wled_preset_2";
      data.option = "Busy";
    }];
  })

  (mkAutomation {
    alias = "Light - Power";
    device = "dumbpad";
    key = "H";
    actions = [{
      action = "light.toggle";
      target.entity_id = "light.office_light";
    }];
  })

  (mkAutomation {
    alias = "Effect - Cyber";
    device = "dumbpad";
    key = "D";
    actions = [
      {
        action = "scene.turn_on";
        target.entity_id = "scene.office_effect_cyber";
      }
    ];
  })
  (mkAutomation {
    alias = "Effect - Glows";
    device = "dumbpad";
    key = "E";
    actions = [
      {
        action = "scene.turn_on";
        target.entity_id = "scene.office_effect_glows";
      }
    ];
  })
  (mkAutomation {
    alias = "Effect - Pinky";
    device = "dumbpad";
    key = "F";
    actions = [
      {
        action = "scene.turn_on";
        target.entity_id = "scene.office_effect_pinky";
      }
    ];
  })
  (mkAutomation {
    alias = "Effect - Off";
    device = "dumbpad";
    key = "G";
    actions = [
      {
        action = "scene.turn_on";
        target.entity_id = "scene.office_effect_off";
      }
    ];
  })

  (mkAutomation {
    alias = "Fan - Toggle";
    device = "dumbpad";
    key = "J";
    actions = [
      {
        action = "fan.toggle";
        target.area_id = "office";
      }
    ];
  })

  (mkAutomation {
    alias = "Media - Play";
    device = "dumbpad";
    key = "MUTE";
    actions = [
      (mkMediaPlayerAction "mpd" "play_pause" { })
    ];
  })

  (mkAutomation {
    alias = "Media - Prev";
    device = "dumbpad";
    key = "MUTE";
    actions = [
      (mkMediaPlayerAction "mpd" "previous_track" { })
    ];
  })
  (mkAutomation {
    alias = "Media - Next";
    device = "dumbpad";
    key = "MUTE";
    actions = [
      (mkMediaPlayerAction "mpd" "next_track" { })
    ];
  })

  (mkAutomation {
    alias = "Media - Volume Down";
    device = "dumbpad";
    key = "VOLUMEDOWN";
    actions = [
      (mkMediaPlayerAction "toiler_snapcast_group" "volume_down" { })
    ];
  })
  (mkAutomation {
    alias = "Media - Volume Up";
    device = "dumbpad";
    key = "VOLUMEUP";
    actions = [
      (mkMediaPlayerAction "toiler_snapcast_group" "volume_up" { })
    ];
  })

  (mkAutomation {
    alias = "Media - Playlist";
    device = "dumbpad";
    key = "CONFIG";
    actions = [
      {
        action = "scene.turn_on";
        target.entity_id = "scene.office_music";
      }
    ];
  })
]
