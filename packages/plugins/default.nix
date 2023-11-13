{ curl, vimUtils, neovimUtils, inputs }:
let
  version = "master";
  buildVim = name: src: vimUtils.buildVimPlugin {
    inherit version;
    pname = name;
    src = src;
  };
  buildNeovim = name: src: neovimUtils.buildNeovimPlugin {
    inherit version;
    pname = name;
    src = src;
  };
in
# TODO simple overrideAttrs does not work here :(
rec {
  SchemaStore-nvim = buildVim "SchemaStore.nvim" inputs.SchemaStore-nvim;
  boole-nvim = (buildVim "boole.nvim" inputs.boole-nvim).overrideAttrs {
    nvimRequireCheck = "boole";
  };
  cmp-buffer = buildVim "cmp-buffer" inputs.cmp-buffer;
  cmp-nvim-lsp = buildVim "cmp-nvim-lsp" inputs.cmp-nvim-lsp;
  cmp-path = buildVim "cmp-path" inputs.cmp-path;
  cmp_luasnip = buildVim "cmp_luasnip" inputs.cmp_luasnip;
  comment-nvim = buildVim "comment.nvim" inputs.comment-nvim;
  copilot-cmp = buildVim "copilot-cmp" inputs.copilot-cmp;
  copilot-lua = buildVim "copilot.lua" inputs.copilot-lua;
  dressing-nvim = buildVim "dressing.nvim" inputs.dressing-nvim;
  fidget-nvim = buildVim "fidget.nvim" inputs.fidget-nvim;
  friendly-snippets = buildVim "friendly-snippets" inputs.friendly-snippets;
  git-conflict-nvim = buildVim "git-conflict.nvim" inputs.git-conflict-nvim;
  gitsigns-nvim = (buildNeovim "gitsigns.nvim" inputs.gitsigns-nvim).overrideAttrs {
    doInstallCheck = true;
    nvimRequireCheck = "gitsigns";
  };
  harpoon = (buildVim "harpoon" inputs.harpoon).overrideAttrs {
    dependencies = [ plenary-nvim ];
    # fails on missing plenary, why? seems like dependencies above are not available during this check.
    # so what do they do?
    # nvimRequireCheck = "harpoon";
  };
  heirline-nvim = buildVim "heirline.nvim" inputs.heirline-nvim;
  kanagawa-nvim = buildVim "kanagawa.nvim" inputs.kanagawa-nvim;
  luasnip = buildVim "luasnip" inputs.luasnip;
  neo-tree-nvim = (buildVim "neo-tree.nvim" inputs.neo-tree-nvim).overrideAttrs {
    dependencies = [ plenary-nvim nui-nvim ];
    nvimRequireCheck = "neo-tree";
  };
  neodev-nvim = buildVim "neodev.nvim" inputs.neodev-nvim;
  nui-nvim = buildVim "nui.nvim" inputs.nui-nvim;
  nvim-cmp = (buildNeovim "nvim-cmp" inputs.nvim-cmp).overrideAttrs {
    nvimRequireCheck = "cmp";
  };
  nvim-dap = buildVim "nvim-dap" inputs.nvim-dap;
  nvim-dap-ui = buildVim "nvim-dap-ui" inputs.nvim-dap-ui;
  nvim-dap-virtual-text = buildVim "nvim-dap-virtual-text" inputs.nvim-dap-virtual-text;
  nvim-luaref = buildVim "nvim-luaref" inputs.nvim-luaref;
  nvim-navic = buildVim "nvim-navic" inputs.nvim-navic;
  nvim-treesitter-context = buildVim "nvim-treesitter-context" inputs.nvim-treesitter-context;
  nvim-treesitter-textobjects = buildVim "nvim-treesitter-textobjects" inputs.nvim-treesitter-textobjects;
  nvim-web-devicons = buildVim "nvim-web-devicons" inputs.nvim-web-devicons;
  omnisharp-extended-lsp-nvim = buildVim "omnisharp-extended-lsp.nvim" inputs.omnisharp-extended-lsp-nvim;
  plenary-nvim = (buildNeovim "plenary.nvim" inputs.plenary-nvim).overrideAttrs {
    postPatch = ''
      sed -Ei lua/plenary/curl.lua \
          -e 's@(command\s*=\s*")curl(")@\1${curl}/bin/curl\2@'
    '';
    nvimRequireCheck = "plenary";
  };
  telescope-fzf-native-nvim = (buildVim "telescope-fzf-native.nvim" inputs.telescope-fzf-native-nvim).overrideAttrs {
    dependencies = [ telescope-nvim ];
    buildPhase = "make";
  };
  telescope-nvim = (buildNeovim "telescope.nvim" inputs.telescope-nvim).overrideAttrs {
    dependencies = [ plenary-nvim ];
    nvimRequireCheck = "telescope";
  };
  undotree = buildVim "undotree" inputs.undotree;
  vim-fugitive = buildVim "vim-fugitive" inputs.vim-fugitive;
  which-key-nvim = buildVim "which-key.nvim" inputs.which-key-nvim;
}
