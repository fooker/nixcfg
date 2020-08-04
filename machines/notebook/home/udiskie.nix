{ ... }:

{
  services.udiskie = {
    automount = true;
    notify = true;
    tray = true;
  };
}