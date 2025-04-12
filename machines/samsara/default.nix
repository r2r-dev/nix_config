{
  config,
  outputs,
  ...
}:
{
  imports = with outputs.nixosModules; [
    impermanence
    bluetooth
    boot
    cloud
    desktop
    fans
    kernel
    network
    nix
    nvidia
    prompter
    rgb
    sound
    ssh
    steam
    xbox
    zerotier

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  r2r.impermanence.enable = true;

      nixpkgs.overlays = [
        (final: prev: {
          # Upgrade linux-firmware, the ath12k firmware is broken on the latest official version.
          linux-firmware = prev.linux-firmware.overrideAttrs rec {
            version = "f4e75db20a11ed07b86017f76c7b428e1fa3f40d";
            src = final.fetchzip {
              url = "https://gitlab.com/kernel-firmware/linux-firmware/-/archive/f4e75db20a11ed07b86017f76c7b428e1fa3f40d/linux-firmware-f4e75db20a11ed07b86017f76c7b428e1fa3f40d.zip";
              hash = "sha256-WmCw9xRUP8HT3yY5EEJVSbUEVAKCJ2wk3KNoApsPzMU=";
            };
          };
        })
      ];
  age = {
    identityPaths = [
      "/persist/etc/ssh/ssh_host_ed25519_key"
      "/persist/etc/ssh/ssh_host_rsa_key"
    ];
    secrets = {
      "r2r.passwd".file = ../../secrets/r2r.passwd.age;
    };
  };

  hardware = {
    enableAllFirmware = true; # ?rgb?
  };

  time.timeZone = "Europe/Warsaw";

  # Enable OpenGL
  hardware.graphics = {
    enable32Bit = true;
    enable = true;
  };

  users = {
    mutableUsers = false;
    users = {
      r2r = {
        isNormalUser = true;
        hashedPasswordFile = config.age.secrets."r2r.passwd".path;
        extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      };
    };
  };

  home-manager.users.r2r =
    { pkgs, ... }:
    {
      nixpkgs = {
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
      };
      nix = {
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
      };
      home.packages = with pkgs; [
        python3
        discord
        stremio
        git
        keepassxc
        nixfmt-rfc-style
        protonvpn-cli
        protonvpn-gui
        signal-desktop
        sshx # TODO ssh module
        sshfs # TODO ssh module
      ];
      programs = {
        bash.enable = true;
        firefox.enable = true;
        vim.enable = true;
      };

      # The state version is required and should stay at the version you
      # originally installed.
      home.stateVersion = "24.11";
    };

  system.stateVersion = "24.11";
}
