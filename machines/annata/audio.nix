{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.gpd.pocket4.audioEnhancement;
in
{
  options = {
    hardware.gpd.pocket4.audioEnhancement = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Create a new audio device called "GPD Speakers",
          which applies sound tuning before sending the audio out to the speakers.
          This option requires PipeWire and WirePlumber.

          The filter chain includes the following:
            - Pyschoacoustic bass enhancement
            - Loudness compensation
            - Equalizer
            - Slight compression

          This option has been optimised for the GPD Pocket 4.

          Before applying, ensure the speakers are set to 100%,
          because the volumes compound and the raw speaker device will be hidden by default.

          You might also need to re-select the default output device.

          In some cases, the added bass will vibrate the keyboard cable leading to a rattling sound,
          a piece of foam can be used to mitigate this.
        '';
      };

      hideRawDevice = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Hide the raw speaker device.
          This option is enabled by default, because keeping the raw speaker device can lead to volume conflicts.
        '';
      };

      rawDeviceName = lib.mkOption {
        type = lib.types.str;
        example = "alsa_output.pci-0000_c5_00.6.analog-stereo";
        default = "alsa_output.pci-0000_c5_00.6.analog-stereo";
        description = ''
          The name of the raw speaker device. This will vary by device.
          You can get this by running `pw-dump | grep -C 20 pci-0000`.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (
    let
      outputName = cfg.rawDeviceName;
      prettyName = "GPD Speakers";

      # These are pre-made decibel to linear value conversions, since Nix doesn't have pow().
      # Use the formula `10 ** (db / 20)` to calculate.

      json = pkgs.formats.json { };

      # The filter chain, heavily inspired by the asahi-audio project: https://github.com/AsahiLinux/asahi-audio
      filter-chain = json.generate "filter-chain.json" {
        "node.description" = prettyName;
        "media.name" = prettyName;
        "filter.graph" = {
          nodes = [
            {
              type = "lv2";
              plugin = "https://chadmed.au/bankstown";
              name = "bassex";
              control = {
                bypass = 0;
                amt = 1.45;
                sat_second = 1.65;
                sat_third = 2.20;
                blend = 1.0;
                ceil = 200.0;
                floor = 20.0;
                final_hp = 120.0;
              };
            }
            {
              type = "lv2";
              plugin = "http://lsp-plug.in/plugins/lv2/loud_comp_mono";
              name = "ell";
              control = {
                enabled = 1;
                input = 1.0;
                fft = 2;
              };
            }
            {
              type = "lv2";
              plugin = "http://lsp-plug.in/plugins/lv2/loud_comp_mono";
              name = "elr";
              control = {
                enabled = 1;
                input = 1.0;
                fft = 2;
              };
            }
            {
              type = "builtin";
              label = "convolver";
              name = "convL";
              config = {
                filename = [
                  "/etc/gpd-audio/gpd-pocket-4-mp-48k-l.wav"
                ];
                channel = 0;
                gain = 1.0;
              };
            }
            {
              type = "builtin";
              label = "convolver";
              name = "convR";
              config = {
                filename = [
                  "/etc/gpd-audio/gpd-pocket-4-mp-48k-r.wav"
                ];
                channel = 0;
                gain = 1.0;
              };
            }
            {
              type = "lv2";
              plugin = "http://lsp-plug.in/plugins/lv2/mb_compressor_stereo";
              name = "woofer_bp";
              control = {
                mode = 0;
                ce_0 = 1;
                sla_0 = 5.0;
                cr_0 = 1.75;
                al_0 = 0.725;
                at_0 = 1.0;
                rt_0 = 100;
                kn_0 = 0.125;
                cbe_1 = 1;
                sf_1 = 380.0;
                ce_1 = 0;
                cbe_2 = 0;
                ce_2 = 0;
                cbe_3 = 0;
                ce_3 = 0;
                cbe_4 = 0;
                ce_4 = 0;
                cbe_5 = 0;
                ce_5 = 0;
                cbe_6 = 0;
                ce_6 = 0;
              };
            }
            {
              type = "lv2";
              plugin = "http://lsp-plug.in/plugins/lv2/compressor_stereo";
              name = "woofer_lim";
              control = {
                sla = 5.0;
                al = 1.0;
                at = 1.0;
                rt = 100.0;
                cr = 15.0;
                kn = 0.5;
              };
            }
          ];
          # Now, we're chaining together the modules instantiated above.
          links = [
            {
              output = "bassex:out_l";
              input = "ell:in";
            }
            {
              output = "bassex:out_r";
              input = "elr:in";
            }
            {
              output = "ell:out";
              input = "convL:In";
            }
            {
              output = "elr:out";
              input = "convR:In";
            }
            {
              output = "convL:Out";
              input = "woofer_bp:in_l";
            }
            {
              output = "convR:Out";
              input = "woofer_bp:in_r";
            }
            {
              output = "woofer_bp:out_l";
              input = "woofer_lim:in_l";
            }
            {
              output = "woofer_bp:out_r";
              input = "woofer_lim:in_r";
            }
          ];

          inputs = [
            "bassex:in_l"
            "bassex:in_r"
          ];
          outputs = [
            "woofer_lim:out_l"
            "woofer_lim:out_r"
          ];

          # This makes pipewire's volume control actually control the loudness comp module
          "capture.volumes" = [
            {
              control = "ell:volume";
              min = -42.5;
              max = 0.0;
              scale = "cubic";
            }
            {
              control = "elr:volume";
              min = -42.5;
              max = 0.0;
              scale = "cubic";
            }
          ];
        };
        "capture.props" = {
          "node.name" = "audio_effect.laptop-convolver";
          "media.class" = "Audio/Sink";
          "audio.channels" = "2";
          "audio.position" = [
            "FL"
            "FR"
          ];
          "audio.allowed-rates" = [
            44100
            48000
            #88200
            #96000
            #176400
            #192000
          ];
          "device.api" = "dsp";
          "node.virtual" = "false";

          # Lower seems to mean "more preferred",
          # bluetooth devices seem to be ~1000, speakers seem to be ~2000
          # since this is between the two, bluetooth devices take over when they connect,
          # and hand over to this instead of the speakers when they disconnect.
          "priority.session" = 1500;
          "priority.driver" = 1500;
          "state.default-volume" = 0.343;
          "device.icon-name" = "audio-card-analog-pci";
        };
        "playback.props" = {
          "node.name" = "audio_effect.laptop-convolver";
          "target.object" = outputName;
          "node.passive" = "true";
          "audio.channels" = "2";
          "audio.allowed-rates" = [
            44100
            48000
            #88200
            #96000
            #176400
            #192000
          ];
          "audio.position" = [
            "FL"
            "FR"
          ];
          "device.icon-name" = "audio-card-analog-pci";
        };
      };

      configPackage =
        (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/99-laptop.conf" ''
          monitor.alsa.rules = [
            {
              matches = [{ node.name = "${outputName}" }]
              actions = {
                update-props = {
                  audio.allowed-rates = [44100, 48000]
                }
              }
            }
          ]

          node.software-dsp.rules = [
            {
              matches = [{ node.name = "${outputName}" }]
              actions = {
                create-filter = {
                  filter-path = "${filter-chain}"
                  hide-parent = ${lib.boolToString cfg.hideRawDevice}
                }
              }
            }
          ]

          wireplumber.profiles = {
            main = { node.software-dsp = "required" }
          }
        '')
        // {
          passthru.requiredLv2Packages = with pkgs; [
            lsp-plugins
            bankstown-lv2
          ];
        };
    in
    {
      services.pipewire.wireplumber.configPackages = [
        configPackage
      ];

      # Pipewire is needed for this.
      services.pipewire.enable = lib.mkDefault true;
      environment.etc."gpd-audio/gpd-pocket-4-mp-48k-l.wav".source =
        ./gpd-pocket-4-mp-48k-l.wav;
      environment.etc."gpd-audio/gpd-pocket-4-mp-48k-r.wav".source =
        ./gpd-pocket-4-mp-48k-r.wav;
    }
  );
}
