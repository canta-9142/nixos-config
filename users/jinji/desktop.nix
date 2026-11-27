{ inputs, ... }:
{
  imports = [
    ./nixos.nix
    inputs.home-manager.nixosModules.home-manager
  ];
  users.users.jinji.extraGroups = [
    "networkManager"
    "input"
    "audio"
    "video"
  ];
  home-manager = {
    users.jinji = import ./home.nix;
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
  };

  sops = {
    defaultSopsFile = ../../secrets/ssh.yaml;
    age = {
      keyFile = "/home/jinji/.config/sops/age/keys.txt";
      generateKey = false;
    };
    secrets.ssh_private_key = {
      owner = "jinji";
      mode = "0400";
    };
  };

  environment.variables.SOPS_AGE_KEY_FILE = "/home/jinji/.config/sops/age/keys.txt";
}
