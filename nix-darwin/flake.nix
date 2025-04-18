{
  description = "System Configuration With Determinate (Single File)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, darwin, nix-homebrew, flake-utils, ... }:
  let
    system = "aarch64-darwin";
  in
  {
    darwinConfigurations."kogomac" = darwin.lib.darwinSystem {
      inherit system;
      modules = [
        ({ config, pkgs, ... }: {
          nix.enable = false; # Important: Disable nix-darwin's Nix management for Determinate

          nixpkgs.config.allowUnfree = true;

          environment.systemPackages = with pkgs; [
            sketchybar
            qmk
            gdal
            neovim
            lazygit
            ripgrep
            fzf
            alacritty
            alacritty-theme
            tmux
            zsh
            oh-my-zsh
            bat
            eza
            zoxide
            zsh-powerlevel10k
            htop
            tig
            just
            jq
            fd
            git
            mkalias
            cmake
            awscli2
            postgresql_16
            fswatch
            vscode-langservers-extracted
            nodePackages_latest.typescript-language-server
            typescript
          ];

        fonts.packages = [
           pkgs.nerd-fonts._0xproto
           pkgs.nerd-fonts.droid-sans-mono
           pkgs.nerd-fonts.fira-code
         ];

          homebrew = {
            enable = true;
            casks = [
              "hammerspoon"
              "firefox"
              "iina"
              "the-unarchiver"
              "raycast"
            ];
          };

          system.defaults = {
            dock.autohide = true;
            dock.mru-spaces = false;
            finder.AppleShowAllExtensions = true;
            finder._FXShowPosixPathInTitle = true;
            NSGlobalDomain.AppleShowAllExtensions = true;
            NSGlobalDomain.AppleInterfaceStyle = "Dark";
            NSGlobalDomain.AppleScrollerPagingBehavior = true;
          };

          system.keyboard = {
            enableKeyMapping = true;
            remapCapsLockToControl = true;
          };

          system.activationScripts.applications.text = let
            env = pkgs.buildEnv {
              name = "system-applications";
              paths = config.environment.systemPackages;
              pathsToLink = "/Applications";
            };
          in
          pkgs.lib.mkForce ''
            # Set up applications.
            echo "setting up /Applications..." >&2
            rm -rf /Applications/Nix\ Apps
            mkdir -p /Applications/Nix\ Apps
            find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
            while read -r src; do
              app_name=$(basename "$src")
              echo "copying $src" >&2
              ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
            done
          '';

          # Configuration revision
          system.configurationRevision = config.system.build.gitRevision or null;

          # System state version (must be a valid release version)
          system.stateVersion = "23.11";
        })

        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "kogo";
            autoMigrate = true;
          };
        }
      ];
    };

    packages.${system}.default = self.darwinConfigurations."kogomac".config.system.build.toplevel;
  };
}

