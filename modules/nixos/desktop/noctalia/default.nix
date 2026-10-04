# Noctalia: Hyprland with the noctalia shell and greeter. The noctalia
# home-manager module is made available to the primary user
# (programs.noctalia in their home config).
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.my.desktop.noctalia;
in
{
  options.my.desktop.noctalia = {
    enable = lib.mkEnableOption "the noctalia desktop environment";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;
    programs.noctalia = {
      enable = true;

      # Enables NetworkManager, Bluetooth, UPower, and a power profile service.
      recommendedServices.enable = true;
    };
    services.displayManager.noctalia-greeter = {
      enable = true;
      passwordlessSyncUsers = [ config.my.user.name ];
      settings = {
        appearance.hide_logo = lib.mkDefault true;
        keyboard.layout = config.my.keyboard.layout;
      };
    };

    # Terminal used by the Hyprland config; X11 apps under the session.
    environment.systemPackages = with pkgs; [
      kitty
      xwayland-satellite
    ];

    home-manager.users.${config.my.user.name}.imports = [
      inputs.noctalia.homeModules.default
    ];
  };
}
