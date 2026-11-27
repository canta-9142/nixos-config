{ config, pkgs, ... }:

{
  programs = {
    fish = {
      enable = true;

      functions = {
        fastfetch = ''
          set -l options
          if test "$COLUMNS" -le 130
            set -a options --config "${config.xdg.configHome}/fastfetch/narrow.jsonc"
          end

          if contains -- "$TERM" xterm-kitty xterm-ghostty; or contains -- "$TERM_PROGRAM" kitty ghostty
            set -a options --logo-type kitty-direct
          else
            set -a options --logo-type builtin --logo nixos
          end

          ${pkgs.fastfetch}/bin/fastfetch $options $argv
        '';
      };

      interactiveShellInit = ''
        set fish_greeting ""

        fastfetch;
      '';

      plugins = [
        {
          name = "fzf-fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
      ];
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    fzf = {
      enable = true;
      # fzf-fish provides the Fish key bindings.
      enableFishIntegration = false;
    };

    oh-my-posh = {
      enable = true;
      enableFishIntegration = true;
      configFile = ./config.omp.json;
    };
  };
}
