{config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "23.05";
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  fonts.packages = [
    pkgs.font-awesome
    pkgs.roboto
    pkgs.nerdfonts
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.kernelModules = ["amdgpu"];
    kernelModules = [ "uinput" ];
    tmp.cleanOnBoot = true;
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    enableRedistributableFirmware = true;

    opengl = {
      enable=true;
      extraPackages = [
        pkgs.rocm-opencl-icd
        pkgs.rocm-opencl-runtime
        pkgs.amdvlk
      ];

      extraPackages32 = [ pkgs.driversi686Linux.amdvlk  ];
      driSupport = true;
      driSupport32Bit = true;
    };

  };

  networking = {
    hostName = "larstop";
    networkmanager.enable = true;
    proxy.noProxy = "127.0.0.1, localhost, internal.domain";
    firewall.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-hyprland ]; 
  };

  sound.enable = true;
  security.rtkit.enable = true;

  users.users.ltm = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" "networkmanager" "audio" "libvirtd"];
    password="ltm";

    packages = [
      pkgs.firefox
      pkgs.thunderbird
      pkgs.chromium

      pkgs.discord
      pkgs.telegram-desktop
      pkgs.slack
      pkgs.zoom-us
      pkgs.obs-studio

      pkgs.git
      pkgs.vscodium.fhs
      pkgs.julia-bin
      pkgs.gdb
      pkgs.clang
      pkgs.clang-tools

      pkgs.virt-manager
      pkgs.dconf #stores configs, in particular for virt-manager
      pkgs.wayvnc

      pkgs.bitwarden

      pkgs.eza
      pkgs.bat
      pkgs.unzip
      pkgs.neofetch
      pkgs.pcmanfm

      pkgs.gpu-viewer
      pkgs.clinfo
      pkgs.htop
      pkgs.qdirstat

      pkgs.xdg-ninja
    ];
  };

  environment = {
    systemPackages = [
      pkgs.bc #for hyprcalcs
      pkgs.jq #also for waybar
      pkgs.waybar
      pkgs.libnotify
      pkgs.dunst
      pkgs.wbg
      pkgs.libpng
      pkgs.libjpeg
      pkgs.libwebp
      pkgs.kitty
      pkgs.networkmanagerapplet
      pkgs.rofi-wayland
      pkgs.waybar
      pkgs.xdg-desktop-portal
      pkgs.xdg-desktop-portal-hyprland
      pkgs.brightnessctl
      pkgs.grimblast
      pkgs.pqiv #for dialog

      pkgs.nh
    ];

    sessionVariables = rec {
      XDG_CACHE_HOME  = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME   = "$HOME/.local/share";
      XDG_STATE_HOME  = "$HOME/.local/state";

      # Not officially in the specification
      XDG_BIN_HOME    = "$HOME/.local/bin";
      PATH = [ "${XDG_BIN_HOME}" ];

      NIXOS_OZONE_WL = 	''true'';
    };
  };

  #VIRTMANAGER
  virtualisation.libvirtd.enable = true;

  services = {

    blueman = { enable = true; };
    thinkfan = { enable = false; };

    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    tlp = {
      enable = true;
      settings = {

     #CPU_SCALING_GOVERNOR_ON_BAT 	= "performance";
      CPU_SCALING_GOVERNOR_ON_BAT	= "powersave";

     #CPU_ENERGY_PERF_POLICY_ON_BAT 	= "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT 	= "powersave";

      CPU_SCALING_GOVERNOR_ON_AC	= "perfomance";
     #CPU_SCALING_GOVERNOR_ON_AC 	= "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC 	= "performance";
     #CPU_ENERGY_PERF_POLICY_ON_AC 	= "powersave";

      CPU_MIN_PERF_ON_AC 		= 0;
      CPU_MAX_PERF_ON_AC 		= 100;
      CPU_MIN_PERF_ON_BAT 		= 0;
      CPU_MAX_PERF_ON_BAT 		= 100;

      START_CHARGE_THRESH_BAT0 		= 50;
      STOP_CHARGE_THRESH_BAT0 		= 70;

      DEVICES_TO_DISABLE_ON_STARTUP	= "bluetooth";
      };
    };
  };

  #SWA#SQUEAK

  programs.steam.enable = true;
  nixpkgs.overlays = [
    (final: prev: {
      steam = prev.steam.override ({ extraPkgs ? pkgs': [], ... }: {
        extraPkgs = pkgs': (extraPkgs pkgs') ++ (with pkgs'; [
          glfw
        ]);
      });
    })
  ];

  programs = {

    hyprland = {
    	enable = true;
    	xwayland.enable = true;
    };

   /* nixvim = {

      enable = false;
      vimAlias = true;

      extraConfigVim = "set noshowmode";

    	options = {
  	  relativenumber = true; # Show relative line numbers
	    shiftwidth = 2;        # Tab width should be 2
			cursorline = true;
    	};

      highlight.ExtraWhitespace.bg = "gray";
      match.ExtraWhitespace = "\\s\\+$";

      keymaps = [
        { key = "j"; action = "k"; }
        { key = "k"; action = "j"; }
      ];

      colorschemes.gruvbox = {
        enable = true;
        settings.transparent_bg = true;
      };

      extraPlugins = with pkgs.vimPlugins; [
        #vim-be-good
      ];

      plugins = {

        lualine = { enable = true; };
      	treesitter = { enable = true; };
	      indent-blankline = { enable = true; };

	      cmp-vim-lsp.enable = true;

	      lsp = {

          keymaps = {
            silent = true;
            diagnostic = {
              "<leader>k" = "goto_prev";
              "<leader>j" = "goto_next";
            };

            lspBuf = {
              gd = "definition";
              K = "hover";
            };
          };

          servers = {
            bashls.enable = true;
            clangd.enable = true;
            nil_ls.enable = true;
          };

        };

      };

      autoCmd =	[
        {
          event = "FileType";
          pattern = "nix";
          command = "setlocal tabstop=2 shiftwidth=2";
        }
      ];

    };*/

    bash.shellAliases = {
      c="clear";
      b="bat --paging=never";
      cfg="cd /etc/nixos";
      hcfg="cd ~/.config";

      e ="eza --tree --level=1 --all --icons --git";
      e1="eza --tree --level=2 --all --icons --git";
      e2="eza --tree --level=3 --all --icons --git";

      ws="wayvnc 0.0.0.0 5900 --log-level=info";
      wx="wayvncctl wayvnc-exit";
 
      comp="c && g++ -o test test.cpp && ./test";

      rbu="sudo nix-channel --update && sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      squeak-run="cd /home/ltm/Uni/SWA/STST/Squeak6.0-22104-64bit-202206021410-Linux-x64 &&rm output.txt && touch output.txt && steam-run ./squeak.sh ./shared/Squeak6.0-22104-64bit.image >> output.txt ";
    };
  };
}
