{ lib, ... }:

with lib;

let
  devices = [
    # volume_eating
    {
      device_id = "d7b4aace221d17b0d572c959c4240846";
      discovery_id = "0x94deb8fffea9a7ad";
    }

    # volume_living
    {
      device_id = "26e095816cb80f1de7674ac31846b45e";
      discovery_id = "0x94deb8fffe63fd40";
    }
  ];

  # Living Room
  area_id = "f08ba942ab384e1e9e42c7550b0c058e";

  mkTrigger = event: device: {
    platform = "device";
    domain = "mqtt";
    inherit (device) device_id;
    type = "action";
    subtype = event;
    discovery_id = "${device.discovery_id} action_${event}";
  };

  mkAutomation = { alias, event, action }: {
    alias = "Media: ${alias} in Living room";
    trigger = map
      (mkTrigger event)
      devices;
    inherit action;
    mode = "single";
  };

  mkMediaPlayerAction = action: singleton {
    service = "media_player.${action}";
    target.area_id = area_id;
  };

in
[
  (mkAutomation {
    alias = "Pause";
    event = "play_pause";
    action = mkMediaPlayerAction "media_play_pause";
  })

  (mkAutomation {
    alias = "Volume down";
    event = "volume_down";
    action = mkMediaPlayerAction "volume_down";
  })
  (mkAutomation {
    alias = "Volume up";
    event = "volume_up";
    action = mkMediaPlayerAction "volume_up";
  })

  (mkAutomation {
    alias = "Skip next";
    event = "track_next";
    action = mkMediaPlayerAction "media_next_track";
  })
  (mkAutomation {
    alias = "Skip previous";
    event = "track_previous";
    action = mkMediaPlayerAction "media_previous_track";
  })

  (mkAutomation {
    alias = "Scene Off";
    event = "dots_1_long_press";
    action = [{
      service = "scene.turn_on";
      target.entity_id = "scene.media_off";
    }];
  })
  (mkAutomation {
    alias = "Scene Movie";
    event = "dots_2_long_press";
    action = [{
      service = "scene.turn_on";
      target.entity_id = "scene.media_movie";
    }];
  })
]
