{
  config,
  pkgs,
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
  programs.steam.gamescopeSession.enable = true; # Integrates with programs.steam
  programs.steam.gamescopeSession.args = [
    "-W 3840"
    "-H 2160"
    "-w 3840"
    "-h 2160"
    "--fullscreen"
    "--steam"
    "-r 120"
    "--xwayland-count 2"
    "--adaptive-sync"
    "--hdr-enabled"
    "--hdr-itm-enabled"
    "--mangoapp"
  ];

  programs.steam.gamescopeSession.steamArgs = [
    "-pipewire-dmabuf"
    "-gamepadui"
    "-steamos3"
  ];

  services.getty.autologinUser = "r2r";
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "r2r";
  services.displayManager.defaultSession = pkgs.lib.mkForce "steam";

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

  # enable ios tethering
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };

  environment.systemPackages = with pkgs; [
    nur.repos.xddxdd.uncategorized.vk-hdr-layer
    libimobiledevice
    #ifuse # optional, to mount using 'ifuse'
  ];

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
        extraGroups = [
          "wheel"
          "input"
        ]; # Enable ‘sudo’ for the user.
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
        coder
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
