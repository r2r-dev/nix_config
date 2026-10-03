# Persist: ephemeral btrfs root that is rolled back to a blank snapshot on
# every boot, with `my.persist.root` holding the state that survives.
#
# Other modules add their state with `my.persist.directories` / `files`
# unconditionally; the entries only take effect when persistence is enabled.
{
  config,
  lib,
  ...
}:
let
  cfg = config.my.persist;
  entry = lib.types.either lib.types.str lib.types.attrs;
in
{
  options.my.persist = {
    enable = lib.mkEnableOption "the ephemeral btrfs root (rollback on boot)";

    root = lib.mkOption {
      type = lib.types.str;
      default = "/persist";
      description = "Mount point of the persistent volume.";
    };

    directories = lib.mkOption {
      type = lib.types.listOf entry;
      default = [ ];
      description = ''
        Directories to keep across reboots. Same format as
        `environment.persistence.<name>.directories`.
      '';
    };

    files = lib.mkOption {
      type = lib.types.listOf entry;
      default = [ ];
      description = ''
        Files to keep across reboots. Same format as
        `environment.persistence.<name>.files`.
      '';
    };

    rollback = {
      device = lib.mkOption {
        type = lib.types.str;
        example = "/dev/mapper/pool0n0-decrypted";
        description = "Block device of the btrfs pool holding the root subvolume.";
      };
      subvolume = lib.mkOption {
        type = lib.types.str;
        default = "root";
        description = "Subvolume mounted as / and recreated on every boot.";
      };
      blankSnapshot = lib.mkOption {
        type = lib.types.str;
        default = "root-blank";
        description = "Read-only empty snapshot / is restored from.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    my.persist = {
      directories = [ "/var/lib/systemd/coredump" ];
      files = [ "/etc/machine-id" ]; # Needed for SystemD Journal
    };

    environment.persistence.main = {
      persistentStoragePath = cfg.root;
      hideMounts = true;
      inherit (cfg) directories files;
    };
    programs.fuse.userAllowOther = true; # impermanence
    services.btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = [ "/" ];
    };
    boot = {
      supportedFilesystems = [ "btrfs" ];

      initrd = {
        systemd = {
          enable = true;
          services.rollback = {
            description = "Rollback BTRFS root subvolume to a pristine state";
            wantedBy = [
              "initrd.target"
            ];
            after = [
              "create-needed-for-boot-dirs.service"
            ];
            before = [
              "sysroot.mount"
            ];
            unitConfig.DefaultDependencies = "no";
            serviceConfig.Type = "oneshot";
            script = with cfg.rollback; ''
              mkdir -p /mnt
              mount -o subvol=/ ${device} /mnt
              btrfs subvolume list -o /mnt/${subvolume} | cut -f9 -d' ' |
              while read subvolume; do
                echo "Deleting /$subvolume subvolume"
                btrfs subvolume delete "/mnt/$subvolume"
              done &&
              echo "Deleting /${subvolume} subvolume" &&
              btrfs subvolume delete /mnt/${subvolume}
              echo "Restoring blank /${subvolume} subvolume"
              btrfs subvolume snapshot /mnt/${blankSnapshot} /mnt/${subvolume}
              umount /mnt
            '';
          };
        };
      };
    };
  };
}
