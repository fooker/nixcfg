[
  {
    alias = "Media: Pause in Living room";
    trigger = [
      {
        platform = "device";
        domain = "mqtt";
        device_id = "6379f7a0249af7538fd07fdf59d75d96";
        type = "action";
        subtype = "play_pause";
        discovery_id = "0x84b4dbfffe60782b action_play_pause";
      }
      {
        platform = "device";
        domain = "mqtt";
        device_id = "51e72fc22ffdeea1817a736ec6133bba";
        type = "action";
        subtype = "play_pause";
        discovery_id = "0x84b4dbfffe60781f action_play_pause";
      }
    ];
    action = [{
      service = "media_player.media_play_pause";
      target.area_id = "f08ba942ab384e1e9e42c7550b0c058e";
    }];
    mode = "single";
  }
  {
    alias = "Media: Volume down in Living Room";
    trigger = [
      {
        platform = "device";
        domain = "mqtt";
        device_id = "6379f7a0249af7538fd07fdf59d75d96";
        type = "action";
        subtype = "play_pause";
        discovery_id = "0x84b4dbfffe60782b action_rotate_left";
      }
      {
        platform = "device";
        domain = "mqtt";
        device_id = "51e72fc22ffdeea1817a736ec6133bba";
        type = "action";
        subtype = "play_pause";
        discovery_id = "0x84b4dbfffe60781f action_rotate_left";
      }
    ];
    action = [{
      service = "media_player.volume_down";
      target.area_id = "f08ba942ab384e1e9e42c7550b0c058e";
    }];
    mode = "single";
  }
  {
    alias = "Media: Volume up in Living Room";
    trigger = [
      {
        platform = "device";
        domain = "mqtt";
        device_id = "6379f7a0249af7538fd07fdf59d75d96";
        type = "action";
        subtype = "play_pause";
        discovery_id = "0x84b4dbfffe60782b action_rotate_right";
      }
      {
        platform = "device";
        domain = "mqtt";
        device_id = "51e72fc22ffdeea1817a736ec6133bba";
        type = "action";
        subtype = "play_pause";
        discovery_id = "0x84b4dbfffe60781f action_rotate_right";
      }
    ];
    action = [{
      service = "media_player.volume_up";
      target.area_id = "f08ba942ab384e1e9e42c7550b0c058e";
    }];
    mode = "single";
  }
]
