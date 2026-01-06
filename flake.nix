{
  description = "Neovim flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    flint-ls.url = "github:konradmalik/flint-ls";

    neorocks = {
      url = "github:lumen-oss/neorocks";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        neovim-nightly.follows = "neovim-nightly-overlay";
      };
    };
    gen-luarc = {
      url = "github:mrcjkb/nix-gen-luarc-json";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # plugins
    SchemaStore-nvim = {
      url = "github:b0o/SchemaStore.nvim";
      flake = false;
    };
    boole-nvim = {
      url = "github:nat-418/boole.nvim";
      flake = false;
    };
    efmls-configs-nvim = {
      url = "github:creativenull/efmls-configs-nvim";
      flake = false;
    };
    friendly-snippets = {
      url = "github:rafamadriz/friendly-snippets";
      flake = false;
    };
    git-conflict-nvim = {
      url = "github:konradmalik/git-conflict.nvim";
      inputs = {
        gen-luarc.follows = "gen-luarc";
        nixpkgs.follows = "nixpkgs";
      };
    };
    gitsigns-nvim = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    incomplete-nvim = {
      url = "github:konradmalik/incomplete.nvim";
      inputs = {
        gen-luarc.follows = "gen-luarc";
        nixpkgs.follows = "nixpkgs";
      };
    };
    kanagawa-nvim = {
      url = "github:rebelot/kanagawa.nvim";
      flake = false;
    };
    mini-icons = {
      url = "github:echasnovski/mini.icons";
      flake = false;
    };
    nvim-dap = {
      url = "github:mfussenegger/nvim-dap";
      flake = false;
    };
    nvim-dap-ui = {
      url = "github:rcarriga/nvim-dap-ui";
      flake = false;
    };
    nvim-dap-virtual-text = {
      url = "github:theHamsta/nvim-dap-virtual-text";
      flake = false;
    };
    nvim-lspconfig = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };
    nvim-luaref = {
      url = "github:milisims/nvim-luaref";
      flake = false;
    };
    nvim-nio = {
      url = "github:nvim-neotest/nvim-nio";
      flake = false;
    };
    nvim-treesitter = {
      url = "github:iofq/nvim-treesitter-main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-treesitter-context = {
      url = "github:nvim-treesitter/nvim-treesitter-context";
      flake = false;
    };
    oil-nvim = {
      url = "github:stevearc/oil.nvim";
      flake = false;
    };
    plenary-nvim = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };
    telescope-fzf-native-nvim = {
      url = "github:nvim-telescope/telescope-fzf-native.nvim";
      flake = false;
    };
    telescope-live-grep-args-nvim = {
      url = "github:nvim-telescope/telescope-live-grep-args.nvim";
      flake = false;
    };
    telescope-nvim = {
      url = "github:nvim-telescope/telescope.nvim";
      flake = false;
    };
    telescope-ui-select-nvim = {
      url = "github:nvim-telescope/telescope-ui-select.nvim";
      flake = false;
    };
    vim-fugitive = {
      url = "github:tpope/vim-fugitive";
      flake = false;
    };
    which-key-nvim = {
      url = "github:folke/which-key.nvim";
      flake = false;
    };
  };

  nixConfig = {
    extra-trusted-substituters = [
      "https://nix-community.cachix.org"
      "https://konradmalik.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs"
      "konradmalik.cachix.org-1:9REXmCYRwPNL0kAB0IMeTxnMB1Gl9VY5I8w7UVBTtSI="
    ];
  };

  outputs =
    inputs:
    let
      nvim-overlay = import ./nix/overlay.nix { inherit inputs; };

      forAllSystems =
        function:
        inputs.nixpkgs.lib.genAttrs
          [
            "x86_64-linux"
            "aarch64-linux"
            "x86_64-darwin"
            "aarch64-darwin"
          ]
          (
            system:
            function (
              import inputs.nixpkgs {
                inherit system;
                overlays = [
                  nvim-overlay
                  inputs.gen-luarc.overlays.default
                  inputs.neorocks.overlays.default
                  (final: prev: {
                    inherit (inputs.flint-ls.packages.${system}) flint-ls;
                    nvim-nightly = inputs.neovim-nightly-overlay.packages.${system}.default;
                  })
                ];
              }
            )
          );
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          name = "neovim-shell";
          shellHook =
            pkgs.nvim-dev.shellHook
            +
            # bash
            ''
              ln -fs ${pkgs.nvim-luarc-json} ./nvim/.luarc.json
              ln -fs ${pkgs.busted-luarc-json} ./spec/.luarc.json
            '';
          packages =
            (with pkgs; [
              gnumake
              busted-nlua
              luajitPackages.luacheck
              stylua
            ])
            ++ (with pkgs; [
              nvim-typecheck
              nvim-dev
            ]);
        };
      });

      packages = forAllSystems (pkgs: {
        default = pkgs.nvim-pkg;
        nvim = pkgs.nvim-pkg;
        nvim-dev = pkgs.nvim-dev;
      });

      apps = forAllSystems (
        pkgs:
        let
          inherit (pkgs) lib;
        in
        rec {
          default = nvim;
          nvim = {
            type = "app";
            program = lib.getExe pkgs.nvim-pkg;
          };
        }
      );

      checks = forAllSystems (
        pkgs:
        let
          inherit (pkgs) lib;
          mkCheck = pkgs.callPackage ./nix/mkCheck.nix { };
        in
        {
          luacheck = mkCheck "luacheck" ''
            ${lib.getExe pkgs.lua.pkgs.luacheck} --codes --no-cache ./nvim
          '';
          typecheck = mkCheck "typecheck" ''
            ${lib.getExe pkgs.nvim-typecheck} ./nvim
          '';
        }
      );

      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
    };
}
