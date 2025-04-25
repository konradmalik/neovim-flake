{
  description = "Neovim flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    neorocks = {
      url = "github:nvim-neorocks/neorocks";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        neovim-nightly.follows = "neovim-nightly-overlay";
      };
    };
    gen-luarc = {
      url = "github:mrcjkb/nix-gen-luarc-json";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # plugins
    SchemaStore-nvim = {
      url = "github:b0o/SchemaStore.nvim";
      flake = false;
    };
    blink-cmp = {
      url = "github:Saghen/blink.cmp";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
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
        flake-parts.follows = "flake-parts";
        gen-luarc.follows = "gen-luarc";
        nixpkgs.follows = "nixpkgs";
      };
    };
    gitsigns-nvim = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    harpoon = {
      url = "github:ThePrimeagen/harpoon/harpoon2";
      flake = false;
    };
    incomplete-nvim = {
      url = "github:konradmalik/incomplete.nvim";
      inputs = {
        flake-parts.follows = "flake-parts";
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
      # url = "github:neovim/nvim-lspconfig";
      # FIXME: until https://github.com/neovim/nvim-lspconfig/issues/3776 closed
      url = "github:konradmalik/nvim-lspconfig";
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
    telescope-ui-select-nvim = {
      url = "github:nvim-telescope/telescope-ui-select.nvim";
      flake = false;
    };
    telescope-nvim = {
      url = "github:nvim-telescope/telescope.nvim";
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

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      imports = [ ./flake ];
    };
}
