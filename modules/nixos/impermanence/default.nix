{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.r2r.impermanence;
in
{
  options.r2r.impermanence = {
    enable = mkEnableOption "impermanence";

  };
  config = mkIf cfg.enable {
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/lib/systemd/coredump"
      ];
      files = [
        "/etc/machine-id" # Needed for SystemD Journal
      ];
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
            script = ''
              mkdir -p /mnt
              mount -o subvol=/ /dev/mapper/pool0n0-decrypted /mnt
              btrfs subvolume list -o /mnt/root | cut -f9 -d' ' |
              while read subvolume; do
                echo "Deleting /$subvolume subvolume"
                btrfs subvolume delete "/mnt/$subvolume"
              done &&
              echo "Deleting /root subvolume" &&
              btrfs subvolume delete /mnt/root
              echo "Restoring blank /root subvolume"
              btrfs subvolume snapshot /mnt/root-blank /mnt/root
              umount /mnt
            '';
          };
        };
      };
    };
  };
}
