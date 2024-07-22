{ neovimPlugins, pkgs }:
let
  np = neovimPlugins;
in
[
  # treesitter
  {
    plugin = np.nvim-treesitter;
    deps = [
      {
        plugin = np.nvim-treesitter-context;
        optional = true;
      }
      np.nvim-treesitter-textobjects
    ];
  }
  # completion
  {
    plugin = np.nvim-cmp;
    optional = true;
    deps = [
      {
        plugin = np.cmp-buffer;
        optional = true;
      }
      {
        plugin = np.cmp-nvim-lsp;
        optional = true;
      }
      {
        plugin = np.cmp-path;
        optional = true;
      }
      {
        plugin = np.cmp_luasnip;
        optional = true;
        deps = [
          {
            plugin = np.luasnip;
            optional = true;
          }
        ];
      }
      np.friendly-snippets
    ];
  }
  # LSP
  {
    plugin = np.SchemaStore-nvim;
    optional = true;
  }
  # DAP
  {
    plugin = np.nvim-dap;
    optional = true;
    deps = [
      {
        plugin = np.nvim-dap-ui;
        optional = true;
      }
      {
        plugin = np.nvim-dap-ui;
        optional = true;
        deps = [
          {
            plugin = np.nvim-nio;
            optional = true;
          }
        ];
      }
      {
        plugin = np.nvim-dap-virtual-text;
        optional = true;
      }
    ];
  }
  # telescope
  {
    plugin = np.telescope-nvim;
    deps = [
      np.plenary-nvim
      np.telescope-fzf-native-nvim
      np.telescope-ui-select-nvim
    ];
    systemDeps = [
      pkgs.git
      pkgs.fd
      pkgs.fzf
      pkgs.ripgrep
    ];
  }
  # statusline
  np.nvim-web-devicons

  # UI
  np.kanagawa-nvim
  {
    plugin = np.neo-tree-nvim;
    deps = [
      np.nvim-web-devicons
      np.plenary-nvim
      np.nui-nvim
    ];
    systemDeps = [ pkgs.git ];
  }
  {
    plugin = np.todo-comments-nvim;
    optional = true;
    deps = [ np.plenary-nvim ];
  }
  # misc
  np.lz-n-vimPlugin
  {
    plugin = np.boole-nvim;
    optional = true;
  }
  {
    plugin = np.git-conflict-nvim;
    optional = true;
    systemDeps = [ pkgs.git ];
  }
  {
    plugin = np.gitsigns-nvim;
    optional = true;
    systemDeps = [ pkgs.git ];
  }
  np.nvim-luaref
  {
    plugin = np.undotree;
    optional = true;
  }
  {
    plugin = np.vim-fugitive;
    systemDeps = [ pkgs.git ];
  }
  np.which-key-nvim
]
