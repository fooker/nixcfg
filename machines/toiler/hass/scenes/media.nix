[
  {
    name = "Media: Off";
    entities = {
      "cover.projector_screen" = {
        state = "open";
      };
      "switch.projector" = {
        state = "off";
      };
      "media_player.amp" = {
        state = "off";
      };
    };
  }

  {
    name = "Media: Movie";
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
    name = "Media: Gaming";
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
    name = "Media: Music";
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
