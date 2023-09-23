{
  description = "Neovim flake";

  inputs =
    {
      nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
      neovim = {
        # url = "github:neovim/neovim?dir=contrib";
        url = "github:Pegasust/neovim/nix-aarch64-darwin-fix?dir=contrib";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      # plugins
      SchemaStore-nvim = { url = "github:b0o/SchemaStore.nvim"; flake = false; };
      boole-nvim = { url = "github:nat-418/boole.nvim"; flake = false; };
      cmp-buffer = { url = "github:hrsh7th/cmp-buffer"; flake = false; };
      cmp-nvim-lsp = { url = "github:hrsh7th/cmp-nvim-lsp"; flake = false; };
      cmp-path = { url = "github:hrsh7th/cmp-path"; flake = false; };
      cmp_luasnip = { url = "github:saadparwaiz1/cmp_luasnip"; flake = false; };
      comment-nvim = { url = "github:numToStr/Comment.nvim"; flake = false; };
      copilot-cmp = { url = "github:zbirenbaum/copilot-cmp"; flake = false; };
      copilot-lua = { url = "github:zbirenbaum/copilot.lua"; flake = false; };
      dressing-nvim = { url = "github:stevearc/dressing.nvim"; flake = false; };
      fidget-nvim = { url = "github:j-hui/fidget.nvim/legacy"; flake = false; };
      friendly-snippets = { url = "github:rafamadriz/friendly-snippets"; flake = false; };
      gitsigns-nvim = { url = "github:lewis6991/gitsigns.nvim"; flake = false; };
      harpoon = { url = "github:ThePrimeagen/harpoon"; flake = false; };
      heirline-nvim = { url = "github:rebelot/heirline.nvim"; flake = false; };
      indent-blankline-nvim = { url = "github:lukas-reineke/indent-blankline.nvim"; flake = false; };
      kanagawa-nvim = { url = "github:rebelot/kanagawa.nvim"; flake = false; };
      luasnip = { url = "github:L3MON4D3/LuaSnip"; flake = false; };
      neo-tree-nvim = { url = "github:nvim-neo-tree/neo-tree.nvim"; flake = false; };
      neodev-nvim = { url = "github:folke/neodev.nvim"; flake = false; };
      nui-nvim = { url = "github:MunifTanjim/nui.nvim"; flake = false; };
      nvim-cmp = { url = "github:hrsh7th/nvim-cmp"; flake = false; };
      nvim-dap = { url = "github:mfussenegger/nvim-dap"; flake = false; };
      nvim-dap-ui = { url = "github:rcarriga/nvim-dap-ui"; flake = false; };
      nvim-dap-virtual-text = { url = "github:theHamsta/nvim-dap-virtual-text"; flake = false; };
      nvim-lspconfig = { url = "github:neovim/nvim-lspconfig"; flake = false; };
      nvim-luaref = { url = "github:milisims/nvim-luaref"; flake = false; };
      nvim-navic = { url = "github:SmiteshP/nvim-navic"; flake = false; };
      nvim-treesitter-context = { url = "github:nvim-treesitter/nvim-treesitter-context"; flake = false; };
      nvim-treesitter-textobjects = { url = "github:nvim-treesitter/nvim-treesitter-textobjects"; flake = false; };
      nvim-web-devicons = { url = "github:kyazdani42/nvim-web-devicons"; flake = false; };
      omnisharp-extended-lsp-nvim = { url = "github:Hoffs/omnisharp-extended-lsp.nvim"; flake = false; };
      plenary-nvim = { url = "github:nvim-lua/plenary.nvim"; flake = false; };
      telescope-fzf-native-nvim = { url = "github:nvim-telescope/telescope-fzf-native.nvim"; flake = false; };
      telescope-nvim = { url = "github:nvim-telescope/telescope.nvim"; flake = false; };
      undotree = { url = "github:mbbill/undotree"; flake = false; };
      vim-fugitive = { url = "github:tpope/vim-fugitive"; flake = false; };
      which-key-nvim = { url = "github:folke/which-key.nvim"; flake = false; };
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
              stylua
              # language-servers
              nil
              sumneko-lua-language-server
            ];
          };
      });
      overlays = {
        default = final: prev: self.overlays.plugins final prev;
        plugins = final: prev: {
          neovimPlugins =
            { inherit (prev.vimPlugins) nvim-treesitter; }
            // prev.callPackage ./packages/plugins { inherit inputs; };
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
          nvim-luaref = pkgs.neovimPlugins.nvim-luaref;
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
