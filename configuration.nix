# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./packages.nix
  ];

  hardware = {
    graphics.enable32Bit = true;
    graphics.enable = true;
  };

  boot.kernelPackages = pkgs.linuxPackages-rt_latest;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "nfs" ];

  boot.initrd.luks.devices."luks-777a016a-05fd-4599-ba62-0cae943b7f0e".device =
    "/dev/disk/by-uuid/777a016a-05fd-4599-ba62-0cae943b7f0e";
  networking.hostName = "nixtop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lucy = {
    isNormalUser = true;
    description = "Lucy Fiedler";
    extraGroups = [ "networkmanager" "wheel" "dialout" "docker" ];
    packages = with pkgs; [ ];
    shell = pkgs.zsh;
  };
  environment.variables = let
    makePluginPath = format:
      (lib.makeSearchPath format [
        "$HOME/.nix-profile/lib"
        "/run/current-system/sw/lib"
        "/etc/profiles/per-user/$USER/lib"
      ]) + ":$HOME/.${format}";
  in {
    DSSI_PATH = makePluginPath "dssi";
    LADSPA_PATH = makePluginPath "ladspa";
    LV2_PATH = makePluginPath "lv2";
    LXVST_PATH = makePluginPath "lxvst";
    VST_PATH = makePluginPath "vst";
    VST3_PATH = makePluginPath "vst3";
  };
  
  environment.sessionVariables = rec {
    LWR_NO_HARDWARE_CURSORS = 1;
    NIXOS_OZONE_WL = "1";
  };

  programs = rec {
    ssh.startAgent = true;
    hyprland.enable = true;
    hyprland.xwayland.enable = true;
    zsh.enable = true;
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture
        obs-gstreamer
        obs-vkcapture
      ];
    };
    nix-ld.enable = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true
  # ;
  services = {
    desktopManager.plasma6.enable = true;
    displayManager = rec {
      sddm.enable = true;
      sddm.wayland.enable = true;
    };
    fprintd.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
      extraConfig.pipewire = {
        "10-clock-rate" = {
          "context.properties" = {
            "default.clock.allowed-rates" = [ 48000 96000 192000 ];
            "default.clock.rate" = 96000;
          };
        };
      };
    };
    logind.settings.Login.HandlePowerKey = "ignore";
    blueman.enable = true;
    udisks2.enable = true;
    rpcbind.enable = true;
    usbmuxd.enable = true;
    udev.packages = [ pkgs.platformio-core pkgs.openocd ];
  };

  virtualisation.docker.enable = true;

  security = {
    wrappers = {
      mount.source = "${pkgs.util-linux}/bin/mount";
      umount.source = "${pkgs.util-linux}/bin/umount";
    };
  };

  fileSystems = {
    "/mnt/nfs/shtuff" = {
      device = "192.168.5.162:/export/shtuff";
      fsType = "nfs";
      options =
        [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" "user" ];
    };

    "/mnt/nfs/iphone-photos" = {
      device = "192.168.5.162:/export/iphone-photos";
      fsType = "nfs";
      options =
        [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" "user" ];
    };

    "/mnt/nfs/media" = {
      device = "192.168.5.162:/export/media";
      fsType = "nfs";
      options =
        [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" "user" ];
    };
  };
  system.stateVersion = "25.05"; # Did you read the comment?

}
