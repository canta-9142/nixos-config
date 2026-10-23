{ config, pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "nixos-remote-rebuild";
      runtimeInputs = [
        config.nix.package
        pkgs.coreutils
        pkgs.git
        pkgs.openssh
        pkgs.rsync
        pkgs.util-linux
      ];
      text = builtins.readFile ./remote-rebuild.sh;
    })
  ];

  programs.fish = {
    shellFunctions = {
      nsr.body = "nixos-remote-rebuild switch $argv";
      nbr.body = "nixos-remote-rebuild boot $argv";
      "..".body = ''
        cd "../$argv[1]"
      '';
      "...".body = ''
        cd "../../$argv[1]"
      '';
      "....".body = ''
        cd "../../../$argv[1]"
      '';
    };

    shellAbbrs = {
      nb = "nh os boot";
      nbl = "nh os boot --builders '' --max-jobs 10";
      ns = "nh os switch";
      nsl = "nh os switch --builders '' --max-jobs 10";
      nsu = "nh os switch --update";
      mi = "micro";
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
      gds = "git diff --staged";
      gf = "git fetch";
      gl = "git log --graph --all --pretty=format:'%Cred%h%Creset %Cgreen(%cI) -%C(yellow)%d%Creset %s %C(bold blue)<%an>%Creset' --abbrev-commit --date=rfc2822";
      gpl = "git pull";
      gp = "git push";
      gr = "git restore --staged .";
      grs = "git reset --soft HEAD^";
      grm = "git reset --mixed HEAD^";
      grh = "git reset --hard HEAD^";
      gs = "git status";
      gst = "git stash";
      gsw = "git switch -c";
    };
  };
}
