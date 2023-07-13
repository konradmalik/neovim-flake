{
  description = "Neovim flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    neovim = {
      url = "github:neovim/neovim/release-0.9?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-luaref = {
      url = "github:milisims/nvim-luaref";
      flake = false;
    };
    fidget-nvim = {
      url = "github:j-hui/fidget.nvim/legacy";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, neovim, ... }@inputs:
    let
      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ]
          (system:
            function (import nixpkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = [
                self.overlays.neovim
                self.overlays.plugins
              ];
            }));
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell
          {
            name = "neovim-shell";

            packages = with pkgs; [
              # formatters/linters
              nixpkgs-fmt
              # language-servers
              nil
              sumneko-lua-language-server
            ];
          };
      });
      overlays = {
        default = final: prev: self.overlays.plugins final prev;
        plugins = final: prev: {
          vimPlugins = prev.vimPlugins // prev.callPackage ./packages/vimPlugins {
            inherit inputs;
          };
        };
        neovim = final: prev: {
          neovim = neovim.packages.${prev.system}.neovim;
        };
      };
      formatter = forAllSystems (pkgs: pkgs.nixpkgs-fmt);
      packages = forAllSystems (pkgs:
        let
          bundle = self.lib.${pkgs.system}.makeNeovimBundle { };
        in
        {
          default = bundle.nvim;
          neovim = bundle.nvim;
          config = bundle.config;
          nvim-luaref = pkgs.vimPlugins.nvim-luaref;
        });
      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          program = "${self.packages.${pkgs.system}.neovim}/bin/nvim";
        };
      });
      lib = forAllSystems (pkgs: {
        makeNeovimBundle = args: (pkgs.callPackage ./packages/neovim-pde args);
      });
      homeManagerModules.default = import ./modules/hm.nix self;
    };

  nixConfig = {
    extra-trusted-substituters = [
      "https://konradmalik.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "konradmalik.cachix.org-1:9REXmCYRwPNL0kAB0IMeTxnMB1Gl9VY5I8w7UVBTtSI="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs"
    ];
  };
}
