{ config, pkgs, ... }:
{
  # Custom neovim config
  nixpkgs.overlays = [ 
    (self: super: {
    neovim = super.neovim.override {
      viAlias = true;
      vimAlias = true;
      configure = {
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [ nvim-treesitter nvim-cmp cmp-treesitter copilot-vim];
        };
	customRC = builtins.readFile ./config/nvim.conf;
      };
    };
    vscode-with-extensions = super.vscode-with-extensions.override {
    	vscode = pkgs.vscodium;
    	vscodeExtensions = with pkgs.vscode-extensions; [
		bbenoist.nix
		vscodevim.vim
		github.copilot
	];
    };
    }) 
  ];

  # Packages
  home.packages = with pkgs; [
    # Shell
    bash
    
    # Fixes copilot
    nodejs-16_x

    # Apps
    todo-txt-cli
    neovim
    yank
    ranger
    neofetch
    vscode-with-extensions
    
    
    # texlive.combined.scheme-full
    
  ];

  # Options
  programs = {
    git = {
      enable = true;
      userName = "GustavoPeredo";
      userEmail = "gustavomperedo@protonmail.com";
    };
    bash = {
      enable = true;
      bashrcExtra = builtins.readFile ./config/bashrc;
      historyIgnore = [ "ls" "cd" "exit" "history" ];
    };
  };

  # Automatically add tasks to todo
  systemd.user = {
    services = {
      daily_tasks = {
        Unit = {
          Description = "Add daily tasks script";
        };
        Service = {
          ExecStart = ''
            ${pkgs.bash}/bin/bash -c '\
            ${pkgs.todo-txt-cli}/bin/todo.sh -d ${config.home.homeDirectory}/.local/share/todo/todo.cfg archive ; \
            ${pkgs.todo-txt-cli}/bin/todo.sh -d ${config.home.homeDirectory}/.local/share/todo/todo.cfg add "(A) Do exercise @$(date +%%a) +Lifestyle" ; \
            ${pkgs.todo-txt-cli}/bin/todo.sh -d ${config.home.homeDirectory}/.local/share/todo/todo.cfg add "(A) Practice Anki @$(date +%%a) +Uni" ; \
            ${pkgs.todo-txt-cli}/bin/todo.sh -d ${config.home.homeDirectory}/.local/share/todo/todo.cfg add "(B) Organize myself @$(date +%%a) +Lifestyle" '
        '';
        };
      };
      weekly_tasks = {
        Unit = {
          Description = "Add weekly tasks script";
        };
        Service = {
          ExecStart = ''
            ${pkgs.bash}/bin/bash -c '\
            ${pkgs.todo-txt-cli}/bin/todo.sh -d ${config.home.homeDirectory}/.local/share/todo/todo.cfg add "(C) Study mathematics @Mon +Uni" ; \
            ${pkgs.todo-txt-cli}/bin/todo.sh -d ${config.home.homeDirectory}/.local/share/todo/todo.cfg add "(C) Study/add cards Statistik @Tue +Uni" ; \
            ${pkgs.todo-txt-cli}/bin/todo.sh -d ${config.home.homeDirectory}/.local/share/todo/todo.cfg add "(C) Study/add cards BWL @Thu +Uni" ; \
            ${pkgs.todo-txt-cli}/bin/todo.sh -d ${config.home.homeDirectory}/.local/share/todo/todo.cfg add "(C) Study Info @Fri +Uni" ; \
            ${pkgs.todo-txt-cli}/bin/todo.sh -d ${config.home.homeDirectory}/.local/share/todo/todo.cfg add "(C) Study/add cards FOC @Thu +Uni" ; \
            ${pkgs.todo-txt-cli}/bin/todo.sh -d ${config.home.homeDirectory}/.local/share/todo/todo.cfg add "(D) Plan video and write script @Mon +Channel" ; \
            ${pkgs.todo-txt-cli}/bin/todo.sh -d ${config.home.homeDirectory}/.local/share/todo/todo.cfg add "(D) Record videos @Tue +Channel" ; \
            ${pkgs.todo-txt-cli}/bin/todo.sh -d ${config.home.homeDirectory}/.local/share/todo/todo.cfg add "(C) Edit video and publish it @Wed +Channel" ; \
            ${pkgs.todo-txt-cli}/bin/todo.sh -d ${config.home.homeDirectory}/.local/share/todo/todo.cfg add "(D) Livestream @Fri +Channel" ; \
\
            ${pkgs.todo-txt-cli}/bin/todo.sh -d ${config.home.homeDirectory}/.local/share/todo/todo.cfg add "(D) Plan what to do on Saturday @Thu +Lifestyle" ; \
            ${pkgs.todo-txt-cli}/bin/todo.sh -d ${config.home.homeDirectory}/.local/share/todo/todo.cfg add "(C) Adventure time! @Sat +Lifestyle" '
        '';
        };
      };
    };
    timers = {
      daily_tasks = {
        Unit = {
          Description = "Add daily tasks timer";
        };
        Timer = {
          OnCalendar = "daily";
          Persistent = true;
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
      weekly_tasks = {
        Unit = {
          Description = "Add weekly tasks timer";
        };
        Timer = {
          OnCalendar = "weekly";
          Persistent = true;
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
  };

  # Write config files
  home.file = {
    "${config.home.homeDirectory}/.local/share/konsole/konsole.colorscheme".source = ./config/konsole.colorscheme;
    "${config.home.homeDirectory}/.local/share/konsole/Profile 1.profile".source = ./config/konsole.profile;
    "${config.home.homeDirectory}/.local/share/nvim/init.vim".source = ./config/nvim.conf;
  };
}
