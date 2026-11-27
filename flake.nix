{
  description = "My NixOS configurations";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cubiea5e = {
      url = "github:patryk4815/nixos-cubie-a5e";
      flake = false;
    };

    nixpkgs-stable.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";

    lanzaboote.url = "github:nix-community/lanzaboote/v1.2.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    mikuboot.url = "gitlab:EvysGarden/mikuboot";
    mikuboot.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-hazkey.url = "github:aster-void/nix-hazkey";
    nix-hazkey.inputs.nixpkgs.follows = "nixpkgs";

    nix-meltype.url = "github:aster-void/nix-meltype";
    nix-meltype.inputs.nixpkgs.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-stable";

    nclean.url = "github:p0nczek/nclean";
    nclean.inputs.nixpkgs.follows = "nixpkgs";

    qshare.url = "github:canta-9142/qshare";

    niri.url = "github:epireyn/niri-flake";

    # Keep Umbriel's own nixpkgs pin so its binary cache can be used.
    umbriel.url = "github:noctalia-dev/umbriel/cachix";

    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    noctalia.inputs.nixpkgs.follows = "nixpkgs";

    herdr.url = "github:herdrdev/herdr/v0.8.0";

    gitwand.url = "github:canta-9142/GitWand-Nix";
    gitwand.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    look.url = "github:kunkka19xx/look";
    look.inputs.nixpkgs.follows = "nixpkgs";

    ytkew.url = "github:canta-9142/ytkew/feat/add-nix-flake";

    ghgrab.url = "github:abhixdd/ghgrab";
    ghgrab.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-substituters = [
      "https://noctalia.cachix.org"
      "https://look.cachix.org"
    ];

    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "look.cachix.org-1:8elPCeSVBzlDZXqIRKBK9GyLIK/Hoe1xiWZF0ir7uX4="
    ];
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        {
          pkgs,
          system,
          lib,
          ...
        }:
        {
          packages = lib.optionalAttrs (system == "x86_64-linux") {
            rock3b-image = import ./lib/make-extlinux-image.nix {
              pkgs = inputs.nixpkgs.legacyPackages.${system};
              inherit (self.nixosConfigurations.rock3b) config;
              baseName = "rock3b-nvme";
            };
            cubiea5e-image = import ./lib/make-extlinux-image.nix {
              pkgs = inputs.nixpkgs.legacyPackages.${system};
              inherit (self.nixosConfigurations.cubiea5e) config;
              baseName = "cubiea5e-nvme";
            };
          };

          checks = lib.optionalAttrs (system == "x86_64-linux") (
            import ./tests/server-checks.nix {
              inherit inputs self;
              pkgs = inputs.nixpkgs.legacyPackages.${system};
            }
          );
          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              nixfmt-tree
              statix
              deadnix
              nixd
              sops
              age
              inputs.deploy-rs.packages.${system}.default
            ];
          };

          formatter = pkgs.nixfmt-tree;
        };

      flake.deploy.nodes.ryzen = {
        hostname = "ryzen.home.arpa";
        sshUser = "jinji";
        interactiveSudo = true;
        remoteBuild = true;
        profiles.system = {
          user = "root";
          path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.ryzen;
        };
      };

      flake.nixosConfigurations = {
        ryzen = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/ryzen ];
        };
        rock3b = inputs.nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [ ./hosts/rock3b ];
        };
        cubiea5e = inputs.nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit (inputs) cubiea5e; };
          modules = [ ./hosts/cubiea5e ];
        };
      };

      flake.nixosConfigurations.inspiron5425 = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = { inherit inputs; };

        modules = [
          ./hosts/inspiron5425
          { nixpkgs.overlays = import ./overlays { inherit inputs; }; }

          inputs.nix-flatpak.nixosModules.nix-flatpak
          inputs.sops-nix.nixosModules.sops
          inputs.niri.nixosModules.niri
          inputs.lanzaboote.nixosModules.lanzaboote
          inputs.mikuboot.nixosModules.default

          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
            };
          }
        ];
      };
    };
}
