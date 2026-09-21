{ pkgs, ... }:

let
  nh = pkgs.symlinkJoin {
    name = "nh-${pkgs.nh.version}";
    paths = [ pkgs.nh ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nh --set NH_PRESERVE_ENV 0
    '';
  };
in
{
  imports = [ ./fish.nix ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  time.timeZone = "Asia/Tokyo";
  programs.fish.enable = true;
  environment.systemPackages = with pkgs; [
    nh
    micro
    git
    gh
    wget
    curl
    btop
    fish
    ripgrep
    tree
    yazi
    nvme-cli
  ];
  users.users.jinji = {
    isNormalUser = true;
    description = "Kanta IMAI";
    shell = pkgs.fish;
    extraGroups = [ "wheel" ];
  };
}
