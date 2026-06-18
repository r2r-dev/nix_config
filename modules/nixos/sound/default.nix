# Sound: PipeWire audio stack (ALSA/PulseAudio/optional JACK) with rtkit
# and the bluetooth HFP autoswitch disabled.
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.nixos.sound;
in
{
  options.modules.nixos.sound = {
    enable = lib.mkEnableOption "the PipeWire audio stack";
    jack = lib.mkEnableOption "JACK audio support in PipeWire";
    socketActivation = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Start PipeWire and its clients via socket activation.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = cfg.jack;
      socketActivation = cfg.socketActivation;

      # Disable the HFP bluetooth profile, because I always use external
      # microphones anyway. It sucks and sometimes devices end up caught
      # in it even if I have another microphone.
      # TODO: mkif bluetooth
      wireplumber.enable = true;
      wireplumber.extraConfig = {
        "wireplumber.settings" = {
          "bluetooth.autoswitch-to-headset-profile" = false;
        };
      };
    };
  };
}
