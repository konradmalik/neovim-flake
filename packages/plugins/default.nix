{ vimPlugins, vimUtils, inputs }:
let
  version = "master";
  overrideAttrs = plugin: attrs: plugin.overrideAttrs (old: { inherit version; } // attrs);
  buildVim = name: src: vimUtils.buildVimPluginFrom2Nix {
    inherit src version;
    pname = name;
  };
in
{
  SchemaStore-nvim = overrideAttrs vimPlugins.SchemaStore-nvim { src = inputs.SchemaStore-nvim; };
  boole-nvim = overrideAttrs vimPlugins.boole-nvim { src = inputs.boole-nvim; };
  cmp-buffer = overrideAttrs vimPlugins.cmp-buffer { src = inputs.cmp-buffer; };
  cmp-nvim-lsp = overrideAttrs vimPlugins.cmp-nvim-lsp { src = inputs.cmp-nvim-lsp; };
  cmp-path = overrideAttrs vimPlugins.cmp-path { src = inputs.cmp-path; };
  cmp_luasnip = overrideAttrs vimPlugins.cmp_luasnip { src = inputs.cmp_luasnip; };
  comment-nvim = overrideAttrs vimPlugins.comment-nvim { src = inputs.comment-nvim; };
  copilot-cmp = overrideAttrs vimPlugins.copilot-cmp { src = inputs.copilot-cmp; };
  copilot-lua = overrideAttrs vimPlugins.copilot-lua { src = inputs.copilot-lua; };
  dressing-nvim = overrideAttrs vimPlugins.dressing-nvim { src = inputs.dressing-nvim; };
  fidget-nvim = overrideAttrs vimPlugins.fidget-nvim { src = inputs.fidget-nvim; };
  friendly-snippets = overrideAttrs vimPlugins.friendly-snippets { src = inputs.friendly-snippets; };
  gitsigns-nvim = overrideAttrs vimPlugins.gitsigns-nvim { src = inputs.gitsigns-nvim; };
  harpoon = overrideAttrs vimPlugins.harpoon { src = inputs.harpoon; };
  heirline-nvim = overrideAttrs vimPlugins.heirline-nvim { src = inputs.heirline-nvim; };
  indent-blankline-nvim = overrideAttrs vimPlugins.indent-blankline-nvim { src = inputs.indent-blankline-nvim; };
  kanagawa-nvim = overrideAttrs vimPlugins.kanagawa-nvim { src = inputs.kanagawa-nvim; };
  luasnip = overrideAttrs vimPlugins.luasnip { src = inputs.luasnip; };
  neo-tree-nvim = overrideAttrs vimPlugins.neo-tree-nvim { src = inputs.neo-tree-nvim; };
  neodev-nvim = overrideAttrs vimPlugins.neodev-nvim { src = inputs.neodev-nvim; };
  nui-nvim = overrideAttrs vimPlugins.nui-nvim { src = inputs.nui-nvim; };
  nvim-cmp = overrideAttrs vimPlugins.nvim-cmp { src = inputs.nvim-cmp; };
  nvim-dap = overrideAttrs vimPlugins.nvim-dap { src = inputs.nvim-dap; };
  nvim-dap-ui = overrideAttrs vimPlugins.nvim-dap-ui { src = inputs.nvim-dap-ui; };
  nvim-dap-virtual-text = overrideAttrs vimPlugins.nvim-dap-virtual-text { src = inputs.nvim-dap-virtual-text; };
  nvim-lspconfig = overrideAttrs vimPlugins.nvim-lspconfig { src = inputs.nvim-lspconfig; };
  nvim-luaref = buildVim "nvim-luaref" inputs.nvim-luaref;
  nvim-navic = overrideAttrs vimPlugins.nvim-navic { src = inputs.nvim-navic; };
  nvim-treesitter-context = overrideAttrs vimPlugins.nvim-treesitter-context { src = inputs.nvim-treesitter-context; };
  nvim-treesitter-textobjects = overrideAttrs vimPlugins.nvim-treesitter-textobjects { src = inputs.nvim-treesitter-textobjects; };
  nvim-web-devicons = overrideAttrs vimPlugins.nvim-web-devicons { src = inputs.nvim-web-devicons; };
  omnisharp-extended-lsp-nvim = overrideAttrs vimPlugins.omnisharp-extended-lsp-nvim { src = inputs.omnisharp-extended-lsp-nvim; };
  plenary-nvim = overrideAttrs vimPlugins.plenary-nvim { src = inputs.plenary-nvim; };
  telescope-fzf-native-nvim = overrideAttrs vimPlugins.telescope-fzf-native-nvim { src = inputs.telescope-fzf-native-nvim; };
  telescope-nvim = overrideAttrs vimPlugins.telescope-nvim { src = inputs.telescope-nvim; };
  undotree = overrideAttrs vimPlugins.undotree { src = inputs.undotree; };
  vim-fugitive = overrideAttrs vimPlugins.vim-fugitive { src = inputs.vim-fugitive; };
  which-key-nvim = overrideAttrs vimPlugins.which-key-nvim { src = inputs.which-key-nvim; };
}
