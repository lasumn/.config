{config, pkgs, lib, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  system.stateVersion = "23.05";
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Europe/Berlin";
  sound.enable = true;
  security.rtkit.enable = true;

  console = {
    keyMap = "de";
    font = "Lat2-Terminus16";
  };

  fonts.packages = with pkgs; [
    roboto
    nerdfonts
    font-awesome
    fira
    fira-code
  ];

  virtualisation.libvirtd.enable = true;

  networking = {
    hostName = "larstop";
    firewall.enable = true;
    networkmanager.enable = true;
    proxy.noProxy = "127.0.0.1, localhost, internal.domain";
  };

  boot = {
    tmp.cleanOnBoot = true;
    kernelModules = [ "uinput" ];
    initrd.kernelModules = ["amdgpu"];
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  hardware = {
    enableRedistributableFirmware = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    xpadneo.enable = true; #for xbox controllers
    opengl = {
      enable          = true;
      driSupport      = true;
      driSupport32Bit = true;
      extraPackages   = with pkgs; [
        amdvlk
        rocm-opencl-icd
        rocm-opencl-runtime
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
  };

  i18n = {
    defaultLocale       = "en_US.UTF-8";
    extraLocaleSettings = {
      LANG              = "en_US.UTF-8";
      LC_CTYPE          = "en_US.UTF-8";
      LC_NUMERIC        = "en_US.UTF-8";
      LC_TIME           = "en_US.UTF-8";
      LC_COLLATE        = "en_US.UTF-8";
      LC_MONETARY       = "en_US.UTF-8";
      LC_MESSAGES       = "en_US.UTF-8";
      LC_PAPER          = "en_US.UTF-8";
      LC_NAME           = "en_US.UTF-8";
      LC_ADDRESS        = "en_US.UTF-8";
      LC_TELEPHONE      = "en_US.UTF-8";
      LC_MEASUREMENT    = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-wlr
    ];
    wlr.enable = true;
  };

  users.users.ltm = {
    isNormalUser = true;
    password = "ltm"; #stop looking at the password its rude ok i will change it eventually
    extraGroups = [
      "wheel"
      "input"
      "audio"
      "libvirtd"
      "networkmanager"
    ];

    packages = with pkgs; [
      firefox
      chromium
      thunderbird
      bitwarden

      discord
      telegram-desktop
      slack
      zoom-us
      obs-studio
      gimp

      git
      gdb
      clang
      clang-tools
      vscodium.fhs
      texlive.combined.scheme-full
      steam 
      lazygit

      eza
      bat
      unzip
      virt-manager
      dconf #stores configs, in particular for virt-manager
      wayvnc

      gpu-viewer
      clinfo
      htop
      qdirstat
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      libnotify
      dunst
      wbg
      libpng
      libjpeg
      libwebp
      kitty
      networkmanagerapplet
      rofi-wayland
      waybar
      xdg-desktop-portal
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk

      qt5.full
      qt6.full

      xdg-utils #makes opening browser tabs from desktop app links not broken how cool is that

      brightnessctl
      grimblast
      steam-run
      xboxdrv

      git
    ];

    sessionVariables = rec {
      XDG_CACHE_HOME  = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME   = "$HOME/.local/share";
      XDG_STATE_HOME  = "$HOME/.local/state";
      XDG_BIN_HOME    = "$HOME/.local/bin";
      PATH            =["${XDG_BIN_HOME}" ];

      NIXOS_OZONE_WL  = "true";
    };
  };
  security = {
    sudo.enable = false;
    doas = {
      enable = true;
      extraRules = [{
        users = ["ltm"];
        keepEnv = true; 
      }];
    };
  };

  services = {

    blueman     = { enable = true; };
    thinkfan    = { enable = false; };
    mullvad-vpn = { enable = true; package = pkgs.mullvad-vpn; };

    pipewire = {
      enable            = true;
      pulse.enable      = true;
      jack.enable       = true;
      alsa.enable       = true;
      alsa.support32Bit = true;
    };

    tlp = {
      enable = true;
      settings = {
        CPU_MIN_PERF_ON_AC  = 0;
        CPU_MAX_PERF_ON_AC  = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 100;

        START_CHARGE_THRESH_BAT0 = 30;
        STOP_CHARGE_THRESH_BAT0  = 60;

        CPU_SCALING_GOVERNOR_ON_BAT   = "performance"; #"powersave";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "performance"; #"powersave";
        CPU_SCALING_GOVERNOR_ON_AC    = "performance";
        CPU_ENERGY_PERF_POLICY_ON_AC  = "performance";

        #DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth";
      };
    };
  };

  programs = {

    hyprland = {
      enable = true; 
      xwayland.enable = true; 
    };

    bash.shellAliases = {
      c     = "clear";
      b     = "bat --paging=never";
      lg     = "lazygit";
      co    = "codium";
      cfg   = "cd ~/.config";

      e     = "eza --tree --level=1 --all --icons --git";
      e1    = "eza --tree --level=2 --all --icons --git";
      e2    = "eza --tree --level=3 --all --icons --git";

      #ws    = "wayvnc 0.0.0.0 5900 --log-level=info";
      #wx    = "wayvncctl wayvnc-exit";

      comp  = "clear && g++ -std=c++20 -o xxx xxx.cpp && ./xxx";

      rb   = "doas nixos-rebuild switch --flake ~/.config/nixos#nixos";
    };
  };
}
