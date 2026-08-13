{
	description = "My NixOS configurations";

	inputs = {
		flake-utils.url = "github:numtide/flake-utils";
		
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		nixpkgs-stable.url = "github:nixos/nixpkgs?ref=release-26.05";

		home-manager.url = "github:nix-community/home-manager";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";
		
		nix-flatpak.url = "github:gmodena/nix-flatpak";

		sops-nix.url = "github:Mic92/sops-nix";
		sops-nix.inputs.nixpkgs.follows = "nixpkgs-stable";

		nclean.url = "github:p0nczek/nclean";
		nclean.inputs.nixpkgs.follows = "nixpkgs";

		niri.url = "github:sodiboo/niri-flake";
		niri.inputs.nixpkgs.follows = "nixpkgs";

		noctalia.url = "github:noctalia-dev/noctalia/cachix";

		ghostty.url = "github:ghostty-org/ghostty/main";
		ghostty.inputs.nixpkgs.follows = "nixpkgs";

		herdr.url = "github:herdrdev/herdr/v0.8.0";

		codex-cli.url = "github:sadjow/codex-cli-nix";
		codex-cli.inputs.nixpkgs.follows = "nixpkgs";

		gitwand.url = "github:canta-9142/GitWand-Nix";
		gitwand.inputs.nixpkgs.follows = "nixpkgs";

		zen-browser.url = "github:0xc000022070/zen-browser-flake";
		zen-browser.inputs.nixpkgs.follows = "nixpkgs";
	};

	nixConfig = {
		extra-substituters = [
			"https://noctalia.cachix.org"
		];

		extra-trusted-public-keys = [
			"noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
		];
	};

	outputs = inputs@{ self,
					   flake-utils,
					   nixpkgs,
					   home-manager,
					   nix-flatpak,
					   sops-nix,
					   nclean,
					   niri,
					   noctalia,
					   ghostty,
					   herdr,
					   codex-cli,
					   gitwand,
					   ... }:
		let
			system = "x86_64-linux";
			hostname = "nixos";
			overlays = import ./overlays { inherit inputs; };
		in {
			nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
				inherit system;

				specialArgs = { inherit inputs; };

				modules = [
					./hosts/${hostname}
					{ nixpkgs.overlays = overlays; }

					nix-flatpak.nixosModules.nix-flatpak
					sops-nix.nixosModules.sops
					niri.nixosModules.niri

					({ pkgs, ... }: {
						environment.systemPackages = [
							home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default
							nclean.packages.${pkgs.stdenv.hostPlatform.system}.default
							ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
							herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
							codex-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
							gitwand.packages.${pkgs.stdenv.hostPlatform.system}.default
						];
					})
					
					home-manager.nixosModules.home-manager
					{
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
						home-manager.extraSpecialArgs = { inherit inputs; };
						home-manager.users.jinji = import ./users/jinji;
					}
				];
			};
		};
}
