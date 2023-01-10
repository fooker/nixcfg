{ ... }:

[
  {
    alias = "Button: Turn off everything";
    trigger = [
      {
        platform = "device";
        domain = "mqtt";
        device_id = "f58f4678703d7a975a84789ef2e6e1c4";
        type = "action";
        subtype = "play_pause";
        discovery_id = "0x84ba20fffea452d2 action_on";
      }

    ];
    action = [
      {
        service = "switch.turn_off";
        target.entity_id = [
          "switch.projector"
        ];
      }
      {
        service = "light.turn_off";
        target.entity_id = [
          "light.art_light"
        ];
      }
      {
        service = "cover.open_cover";
        target.entity_id = [
          "cover.projector_screen"
        ];
      }
      {
        service = "media_player.turn_off";
        target.entity_id = [
          "media_player.amp"
        ];
      }
    ];
    mode = "single";
  }
]
