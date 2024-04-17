{
  description = "Neovim flake";

  inputs =
    {
      nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
      neovim = {
        url = "github:neovim/neovim?dir=contrib";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      tree-sitter-earthfile = { url = "github:glehmann/tree-sitter-earthfile"; flake = false; };

      # plugins
      SchemaStore-nvim = { url = "github:b0o/SchemaStore.nvim"; flake = false; };
      boole-nvim = { url = "github:nat-418/boole.nvim"; flake = false; };
      cmp-buffer = { url = "github:hrsh7th/cmp-buffer"; flake = false; };
      cmp-nvim-lsp = { url = "github:hrsh7th/cmp-nvim-lsp"; flake = false; };
      cmp-path = { url = "github:hrsh7th/cmp-path"; flake = false; };
      cmp_luasnip = { url = "github:saadparwaiz1/cmp_luasnip"; flake = false; };
      dressing-nvim = { url = "github:stevearc/dressing.nvim"; flake = false; };
      friendly-snippets = { url = "github:rafamadriz/friendly-snippets"; flake = false; };
      git-conflict-nvim = { url = "github:konradmalik/git-conflict.nvim"; flake = false; };
      gitsigns-nvim = { url = "github:lewis6991/gitsigns.nvim"; flake = false; };
      harpoon = { url = "github:ThePrimeagen/harpoon/harpoon2"; flake = false; };
      kanagawa-nvim = { url = "github:rebelot/kanagawa.nvim"; flake = false; };
      luasnip = { url = "github:L3MON4D3/LuaSnip"; flake = false; };
      neo-tree-nvim = { url = "github:nvim-neo-tree/neo-tree.nvim"; flake = false; };
      nui-nvim = { url = "github:MunifTanjim/nui.nvim"; flake = false; };
      nvim-cmp = { url = "github:hrsh7th/nvim-cmp"; flake = false; };
      nvim-dap = { url = "github:mfussenegger/nvim-dap"; flake = false; };
      nvim-dap-ui = { url = "github:rcarriga/nvim-dap-ui"; flake = false; };
      nvim-dap-virtual-text = { url = "github:theHamsta/nvim-dap-virtual-text"; flake = false; };
      nvim-luaref = { url = "github:milisims/nvim-luaref"; flake = false; };
      nvim-nio = { url = "github:nvim-neotest/nvim-nio"; flake = false; };
      nvim-treesitter = { url = "github:nvim-treesitter/nvim-treesitter"; flake = false; };
      nvim-treesitter-context = { url = "github:nvim-treesitter/nvim-treesitter-context"; flake = false; };
      nvim-treesitter-textobjects = { url = "github:nvim-treesitter/nvim-treesitter-textobjects"; flake = false; };
      nvim-web-devicons = { url = "github:kyazdani42/nvim-web-devicons"; flake = false; };
      plenary-nvim = { url = "github:nvim-lua/plenary.nvim"; flake = false; };
      telescope-fzf-native-nvim = { url = "github:nvim-telescope/telescope-fzf-native.nvim"; flake = false; };
      telescope-nvim = { url = "github:nvim-telescope/telescope.nvim"; flake = false; };
      todo-comments-nvim = { url = "github:folke/todo-comments.nvim"; flake = false; };
      undotree = { url = "github:mbbill/undotree"; flake = false; };
      vim-fugitive = { url = "github:tpope/vim-fugitive"; flake = false; };
      which-key-nvim = { url = "github:folke/which-key.nvim"; flake = false; };
    };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      forAllSystems = funcOfPkgs:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ]
          (system: funcOfPkgs nixpkgs.legacyPackages.${system});

      neovimPluginsFor = pkgs:
        let
          tree-sitter-earthfile-grammar = pkgs.tree-sitter.buildGrammar
            {
              language = "earthfile";
              version = inputs.tree-sitter-earthfile.rev;
              src = inputs.tree-sitter-earthfile;
            };
        in
        pkgs.callPackage ./packages/vendoredPlugins.nix
          {
            inherit inputs;
            all-treesitter-grammars =
              pkgs.vimPlugins.nvim-treesitter.allGrammars ++ [ tree-sitter-earthfile-grammar ];
          };
    in
    {
      devShells = forAllSystems (pkgs: {
        default =
          let
            nvim-dev-pkg =
              (self.packages.${pkgs.system}.neovim.override
                { appName = "native"; self-contained = false; include-native-config = false; tmp-cache = true; });
            nvim-dev = pkgs.writeShellScriptBin "nvim-dev"
              ''
                if [[ ! $NVIM_PDE_DEV_NATIVE_CONFIG_PATH ]]; then
                  echo "must set NVIM_PDE_DEV_NATIVE_CONFIG_PATH"
                  exit 1
                fi

                XDG_CONFIG_DIRS="${nvim-dev-pkg.passthru.config}:$NVIM_PDE_DEV_NATIVE_CONFIG_PATH" \
                  ${nvim-dev-pkg}/bin/nvim  -u $NVIM_PDE_DEV_NATIVE_CONFIG_PATH/native/init.lua
              '';
          in
          pkgs.mkShell {
            name = "neovim-shell";
            shellHook = ''
              export NVIM_PDE_DEV_NATIVE_CONFIG_PATH="$PWD/config"
            '';
            packages = with pkgs; [
              stylua
              lua.pkgs.luacheck
              nvim-dev
            ];
          };
      });
      overlays.default = final: prev: {
        neovimPlugins = neovimPluginsFor final;
        neovim = self.packages.${prev.system}.neovim;
      };

      checks = forAllSystems
        (pkgs: {
          luacheck =
            let
              fs = pkgs.lib.fileset;
              sourceFiles = fs.unions [
                ./config/native
                ./.luacheckrc
              ];
              name = "luacheck";
            in
            pkgs.stdenvNoCC.mkDerivation {
              inherit name;
              dontBuild = true;
              src = builtins.path {
                inherit name;
                path = fs.toSource {
                  root = ./.;
                  fileset = sourceFiles;
                };
              };
              doCheck = true;
              nativeBuildInputs = with pkgs; [ lua.pkgs.luacheck ];
              checkPhase = ''
                luacheck --codes --no-cache ./config/native
              '';
              installPhase = ''
                touch "$out"
              '';
            };
        });

      formatter = forAllSystems (pkgs: pkgs.nixpkgs-fmt);
      packages = forAllSystems (pkgs: rec {
        neovim = pkgs.callPackage ./packages/neovim-pde {
          neovim = inputs.neovim.packages.${pkgs.system}.neovim;
          neovimPlugins = neovimPluginsFor pkgs;
        };
        default = neovim;
        config = neovim.passthru.config;
      });
      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          program = "${self.packages.${pkgs.system}.neovim}/bin/nvim";
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
