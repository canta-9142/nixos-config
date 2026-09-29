_:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/common.nix
    ../../modules/system/ssh.nix

    ./core.nix
    ./nix-builder.nix
    ./gc.nix
    ./boot.nix
    ./networking.nix
    ../../modules/system/audio.nix
    ./packages.nix
    ./users.nix
    ../../modules/system/desktop
    ../../modules/system/distrobox.nix
    ../../modules/system/cloudflare-warp.nix
    ../../modules/system/virtualbox.nix
    ../../modules/system/security/luks.nix
    ../../modules/system/security/apparmor.nix
    ../../modules/system/security/sudo.nix
    ../../modules/system/security/sops.nix
  ];

  networking.hostName = "nixos";
  # Forgejo's migrated host key on Mesh port 2222; separate from management SSH.
  programs.ssh.knownHosts.ryzen-forgejo = {
    hostNames = [ "[ryzen.home.arpa]:2222" ];
    publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCrQ8EiAAiVQ5/4cn9Og21VCPVQfyJ5Q7aXsC2g9pBzA2qLCA8GFoZfGQBukWRk2LsQLTD1jIY2QP9HJIAMM9pBLXZnu+Cv9Aptwvw9vrGlUChfMgkWy+t0FhYkrUsTed+Ay7b1UsIeOVnD02IzIp9dInNoURVqak4sYaOgL4+Ha/v6lh+Elq+rGhSVHEgWIuqa1W7Sqn/fKtEratsqwi99ogkEKMRMvRusjBFUA49DMGn5w9CRB4/ilaJBNhfTFVOz1XCJfZzjfONwT+YpB0g8HqbAa9kGHVfRMyHSX93Yz6wSunTNp8RccjmjeqHCRl9EVwmCaXWrWx4OLzNe/CSo3c4SurYa2ekkUIse7rLhyXkKtwz0vYkMFlqpR1rTKKe4W7+n02ur7FzDS7Lcx3ZNwzZqj2SXykhzZNt3bQdsSY7J0kJ6esD3NkIIJxAR6ReylHSXcMOWDyhIuoH4KyyzZZoTPLuFDPiZf3GqsJ6qdw6hAEoBoKYx6xobuW9KSPh/lDsRC//LPxoMAry0Us/n9RAZ/aTFkd+d4mrYtg37wkHhsDvN7ddfPJiqaVsH3MQQpW+itGbp37EYNjdHjwM0vMhMzud93RZPuZFqHxklLLEBYjWdoYW2bFatRdA+VV1tPGfElGjFwqbfC/235Z7k14XTwLjqot9KvKjGYb97ww==";
  };
  system.stateVersion = "26.05";
}
