{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;

    functions.fastfetch = ''
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

    shellAbbrs = {
      nb = "nh os boot";
      ns = "nh os switch";
      nsu = "nh os switch --update";
      mi = "micro";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      g = "git";
      ga = "git add";
      gaa = "git add .";
      gb = "git branch --all";
      gbd = "git branch -d";
      gc = "git commit";
      gca = "git commit -a";
      gcm = "git commit -m";
      gcam = "git commit -a -m";
      gco = "git checkout";
      gd = "git diff";
      gf = "git fetch";
      gl = "git log --graph --all --pretty=format:'%Cred%h%Creset %Cgreen(%cI) -%C(yellow)%d%Creset %s %C(bold blue)<%an>%Creset' --abbrev-commit --date=rfc2822";
      gpl = "git pull";
      gp = "git push";
      gs = "git status";
      gst = "git stash";
      gsw = "git switch -c";
    };

    interactiveShellInit = ''
      set fish_greeting ""
      set -gx NH_FLAKE "/home/jinji/nixos-config#nixos"

      fastfetch;
    '';

    plugins = [
      {
        name = "z";
        src = pkgs.fishPlugins.z.src;
      }
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
    ];
  };

  programs.oh-my-posh = {
    enable = true;
    enableFishIntegration = true;
    configFile = ./config.omp.json;
  };
}
