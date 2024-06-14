{
  description = "Neovim flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    # plugins
    SchemaStore-nvim = {
      url = "github:b0o/SchemaStore.nvim";
      flake = false;
    };
    boole-nvim = {
      url = "github:nat-418/boole.nvim";
      flake = false;
    };
    cmp-buffer = {
      url = "github:hrsh7th/cmp-buffer";
      flake = false;
    };
    cmp-nvim-lsp = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };
    cmp-path = {
      url = "github:hrsh7th/cmp-path";
      flake = false;
    };
    cmp_luasnip = {
      url = "github:saadparwaiz1/cmp_luasnip";
      flake = false;
    };
    friendly-snippets = {
      url = "github:rafamadriz/friendly-snippets";
      flake = false;
    };
    git-conflict-nvim = {
      url = "github:konradmalik/git-conflict.nvim";
      flake = false;
    };
    gitsigns-nvim = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    kanagawa-nvim = {
      url = "github:rebelot/kanagawa.nvim";
      flake = false;
    };
    luasnip = {
      url = "github:L3MON4D3/LuaSnip";
      flake = false;
    };
    neo-tree-nvim = {
      url = "github:nvim-neo-tree/neo-tree.nvim";
      flake = false;
    };
    nui-nvim = {
      url = "github:MunifTanjim/nui.nvim";
      flake = false;
    };
    nvim-cmp = {
      url = "github:hrsh7th/nvim-cmp";
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
    nvim-luaref = {
      url = "github:milisims/nvim-luaref";
      flake = false;
    };
    nvim-nio = {
      url = "github:nvim-neotest/nvim-nio";
      flake = false;
    };
    nvim-treesitter = {
      url = "github:nvim-treesitter/nvim-treesitter";
      flake = false;
    };
    nvim-treesitter-context = {
      url = "github:nvim-treesitter/nvim-treesitter-context";
      flake = false;
    };
    nvim-treesitter-textobjects = {
      url = "github:nvim-treesitter/nvim-treesitter-textobjects";
      flake = false;
    };
    nvim-web-devicons = {
      url = "github:kyazdani42/nvim-web-devicons";
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
    telescope-ui-select-nvim = {
      url = "github:nvim-telescope/telescope-ui-select.nvim";
      flake = false;
    };
    telescope-nvim = {
      url = "github:nvim-telescope/telescope.nvim";
      flake = false;
    };
    todo-comments-nvim = {
      url = "github:folke/todo-comments.nvim";
      flake = false;
    };
    undotree = {
      url = "github:mbbill/undotree";
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

  outputs =
    { self, ... }@inputs:
    let
      nixpkgsFor =
        system:
        (import inputs.nixpkgs {
          localSystem = {
            inherit system;
          };
          overlays = [
            # until https://github.com/NixOS/nixpkgs/issues/317055
            (final: prev: {
              zig_0_12 = prev.zig_0_12.overrideAttrs (_oldAttrs: {
                preConfigure = ''
                  CC=$(type -p $CC)
                  CXX=$(type -p $CXX)
                  LD=$(type -p $LD)
                  AR=$(type -p $AR)
                '';
              });
            })
          ];
        });

      forAllSystems =
        funcOfPkgs:
        inputs.nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ] (system: funcOfPkgs (nixpkgsFor system));

      neovimPluginsFor =
        pkgs:
        pkgs.callPackage ./packages/vendoredPlugins.nix {
          inherit inputs;
          all-treesitter-grammars = pkgs.vimPlugins.nvim-treesitter.allGrammars;
        };
    in
    {
      devShells = forAllSystems (pkgs: {
        default =
          let
            nvim-dev = pkgs.writeShellScriptBin "nvim-dev" ''
              NVIM_PDE_DEV_NATIVE_CONFIG_PATH="$PWD/config" nix run .#neovim-dev
            '';
          in
          pkgs.mkShell {
            name = "neovim-shell";
            packages =
              (with pkgs; [
                stylua
                lua.pkgs.luacheck
              ])
              ++ [
                self.packages.${pkgs.system}.nvim-typecheck
                nvim-dev
              ];

          };
      });
      overlays.default = final: prev: {
        neovimPlugins = neovimPluginsFor final;
        neovim = self.packages.${prev.system}.neovim;
      };

      checks = forAllSystems (
        pkgs:
        let
          fs = pkgs.lib.fileset;
          makeCheckJob =
            name: cmd:
            pkgs.stdenvNoCC.mkDerivation {
              inherit name;
              dontBuild = true;
              dontConfigure = true;
              src = builtins.path {
                inherit name;
                path = fs.toSource {
                  root = ./.;
                  fileset = fs.unions [
                    ./config/native
                    ./.luacheckrc
                  ];
                };
              };
              doCheck = true;
              checkPhase = cmd;
              installPhase = ''
                touch "$out"
              '';
            };
        in
        {
          luacheck = makeCheckJob "luacheck" ''
            ${pkgs.lua.pkgs.luacheck}/bin/luacheck --codes --no-cache ./config/native
          '';
          typecheck = makeCheckJob "typecheck" ''
            ${self.packages.${pkgs.system}.nvim-typecheck}/bin/nvim-typecheck ./config/native
          '';
        }
      );

      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
      packages = forAllSystems (
        pkgs:
        let
          nightlyNeovim = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
          myNeovim = pkgs.callPackage ./packages/neovim-pde {
            neovim = nightlyNeovim;
            neovimPlugins = neovimPluginsFor pkgs;
          };
          myNeovimDev =
            let
              pkg = myNeovim.override {
                appName = "native";
                self-contained = false;
                include-native-config = false;
                tmp-cache = true;
              };
            in
            pkgs.writeShellScriptBin "nvim-dev" ''
              if [[ ! $NVIM_PDE_DEV_NATIVE_CONFIG_PATH ]]; then
                echo "must set NVIM_PDE_DEV_NATIVE_CONFIG_PATH"
                exit 1
              fi

              XDG_CONFIG_DIRS="${pkg.passthru.config}:$NVIM_PDE_DEV_NATIVE_CONFIG_PATH" \
                ${pkgs.lib.getExe pkg} -u $NVIM_PDE_DEV_NATIVE_CONFIG_PATH/native/init.lua
            '';
        in
        {
          default = myNeovim;
          neovim = myNeovim;
          neovim-dev = myNeovimDev;
          config = myNeovim.passthru.config;
          nvim-typecheck = pkgs.callPackage ./packages/nvim-typecheck { neovim = nightlyNeovim; };
        }
      );
      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          program = pkgs.lib.getExe self.packages.${pkgs.system}.neovim;
        };
      });
      homeManagerModules.default = import ./modules/hm.nix self;
    };

  nixConfig = {
    extra-substituters = [
      "https://konradmalik.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "konradmalik.cachix.org-1:9REXmCYRwPNL0kAB0IMeTxnMB1Gl9VY5I8w7UVBTtSI="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs"
    ];
  };
}
