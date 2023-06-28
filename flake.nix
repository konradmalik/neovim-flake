{
  description = "Neovim flake ";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    neovim = {
      url = "github:neovim/neovim/release-0.9?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mini-base16 = {
      url = "github:echasnovski/mini.base16";
      flake = false;
    };
    nvim-luaref = {
      url = "github:milisims/nvim-luaref";
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
                (final: prev: { neovim = neovim.packages.${system}.neovim; })
                (final: prev: {
                  vimPlugins = prev.vimPlugins // final.callPackage ./packages/vimPlugins {
                    inherit inputs;
                  };
                })
                (final: prev: {
                  neovim-pde = (final.callPackage ./packages/neovim-pde { }) { };
                })
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
      formatter = forAllSystems (pkgs: pkgs.nixpkgs-fmt);
      packages = forAllSystems (pkgs: rec {
        default = neovim;
        neovim = pkgs.neovim-pde.nvim;
      });
      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          program = "${pkgs.neovim-pde.nvim}/bin/nvim";
        };
      });
      lib = forAllSystems (pkgs: {
        bundle = pkgs.neovim-pde;
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
