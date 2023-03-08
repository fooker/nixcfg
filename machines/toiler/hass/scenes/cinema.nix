[
  {
    name = "Movie";
    entities = {
      "cover.projector_screen" = {
        state = "closed";
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
      "cover.projector_screen" = {
        state = "closed";
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
      "cover.projector_screen" = {
        state = "open";
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
