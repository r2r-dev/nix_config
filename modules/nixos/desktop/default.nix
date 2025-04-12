_:

{
  # Enable the KDE Plasma Desktop Environment.
  services = {
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
    xserver.xkb.layout = "pl";
  };
}
