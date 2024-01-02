{ curl, vimUtils, neovimUtils, inputs }:
let
  version = "master";
  buildVim = { name, src }: vimUtils.buildVimPlugin {
    inherit src version;
    pname = name;
  };
  buildNeovim = { name, src }: neovimUtils.buildNeovimPlugin {
    inherit src version;
    pname = name;
  };
in
# why not simple overrideAttrs?
  # - does not work for src in buildVimPlugin
  # - plugins internally depend on vimUtils.plenary-nvim and similar either way
rec {
  SchemaStore-nvim = buildVim { name = "SchemaStore.nvim"; src = inputs.SchemaStore-nvim; };
  boole-nvim = (buildVim { name = "boole.nvim"; src = inputs.boole-nvim; }).overrideAttrs {
    nvimRequireCheck = "boole";
  };
  cmp-buffer = buildVim { name = "cmp-buffer"; src = inputs.cmp-buffer; };
  cmp-nvim-lsp = buildVim { name = "cmp-nvim-lsp"; src = inputs.cmp-nvim-lsp; };
  cmp-path = buildVim { name = "cmp-path"; src = inputs.cmp-path; };
  cmp_luasnip = buildVim { name = "cmp_luasnip"; src = inputs.cmp_luasnip; };
  comment-nvim = (buildVim { name = "comment.nvim"; src = inputs.comment-nvim; }).overrideAttrs {
    nvimRequireCheck = "Comment";
  };
  copilot-cmp = buildVim { name = "copilot-cmp"; src = inputs.copilot-cmp; };
  copilot-lua = buildVim { name = "copilot.lua"; src = inputs.copilot-lua; };
  dressing-nvim = buildVim { name = "dressing.nvim"; src = inputs.dressing-nvim; };
  friendly-snippets = buildVim { name = "friendly-snippets"; src = inputs.friendly-snippets; };
  git-conflict-nvim = buildVim { name = "git-conflict.nvim"; src = inputs.git-conflict-nvim; };
  gitsigns-nvim = (buildNeovim { name = "gitsigns.nvim"; src = inputs.gitsigns-nvim; }).overrideAttrs {
    doInstallCheck = true;
    nvimRequireCheck = "gitsigns";
  };
  harpoon = (buildVim { name = "harpoon"; src = inputs.harpoon; }).overrideAttrs {
    nativeBuildInputs = [ plenary-nvim ];
    nvimRequireCheck = "harpoon";
  };
  heirline-nvim = buildVim { name = "heirline.nvim"; src = inputs.heirline-nvim; };
  kanagawa-nvim = buildVim { name = "kanagawa.nvim"; src = inputs.kanagawa-nvim; };
  luasnip = buildVim { name = "luasnip"; src = inputs.luasnip; };
  neo-tree-nvim = (buildVim { name = "neo-tree.nvim"; src = inputs.neo-tree-nvim; }).overrideAttrs {
    nvimRequireCheck = "neo-tree";
  };
  neodev-nvim = buildVim { name = "neodev.nvim"; src = inputs.neodev-nvim; };
  nui-nvim = buildVim { name = "nui.nvim"; src = inputs.nui-nvim; };
  nvim-cmp = (buildNeovim { name = "nvim-cmp"; src = inputs.nvim-cmp; }).overrideAttrs {
    nvimRequireCheck = "cmp";
  };
  nvim-dap = buildVim { name = "nvim-dap"; src = inputs.nvim-dap; };
  nvim-dap-ui = buildVim { name = "nvim-dap-ui"; src = inputs.nvim-dap-ui; };
  nvim-dap-virtual-text = buildVim { name = "nvim-dap-virtual-text"; src = inputs.nvim-dap-virtual-text; };
  nvim-luaref = buildVim { name = "nvim-luaref"; src = inputs.nvim-luaref; };
  nvim-navic = buildVim { name = "nvim-navic"; src = inputs.nvim-navic; };
  nvim-treesitter-context = buildVim { name = "nvim-treesitter-context"; src = inputs.nvim-treesitter-context; };
  nvim-treesitter-textobjects = buildVim { name = "nvim-treesitter-textobjects"; src = inputs.nvim-treesitter-textobjects; };
  nvim-web-devicons = buildVim { name = "nvim-web-devicons"; src = inputs.nvim-web-devicons; };
  omnisharp-extended-lsp-nvim = buildVim { name = "omnisharp-extended-lsp.nvim"; src = inputs.omnisharp-extended-lsp-nvim; };
  plenary-nvim = (buildNeovim { name = "plenary.nvim"; src = inputs.plenary-nvim; }).overrideAttrs {
    postPatch = ''
      sed -Ei lua/plenary/curl.lua \
          -e 's@(command\s*=\s*")curl(")@\1${curl}/bin/curl\2@'
    '';
    nvimRequireCheck = "plenary";
  };
  telescope-fzf-native-nvim = (buildVim { name = "telescope-fzf-native.nvim"; src = inputs.telescope-fzf-native-nvim; }).overrideAttrs {
    buildPhase = "make";
  };
  telescope-nvim = (buildNeovim { name = "telescope.nvim"; src = inputs.telescope-nvim; }).overrideAttrs {
    nvimRequireCheck = "telescope";
  };
  undotree = buildVim { name = "undotree"; src = inputs.undotree; };
  vim-fugitive = buildVim { name = "vim-fugitive"; src = inputs.vim-fugitive; };
  which-key-nvim = buildVim { name = "which-key.nvim"; src = inputs.which-key-nvim; };
}
