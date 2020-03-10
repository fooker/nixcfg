[
  {
    name = "Movie";
    entities = {
      "switch.screen" = {
        state = "on";
      };
      "switch.projector" = {
        state = "on";
      };
      "media_player.amp" = {
        state = "on";
        source = "MEDIA PLAYER";
      };
    };
  }

  {
    name = "Gaming";
    entities = {
      "switch.screen" = {
        state = "on";
      };
      "switch.projector" = {
        state = "on";
      };
      "media_player.amp" = {
        state = "on";
        source = "GAME";
      };
    };
  }

  {
    name = "Music";
    entities = {
      "switch.screen" = {
        state = "off";
      };
      "switch.projector" = {
        state = "off";
      };
      "media_player.amp" = {
        state = "on";
        source = "NETWORK";
      };
    };
  }
]