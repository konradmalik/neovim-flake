{ curl, vimUtils, neovimUtils, inputs, vimPlugins }:
let
  version = "master";
  buildVim = { name, src, nvimRequireCheck ? name, vimCommandCheck ? null }: vimUtils.buildVimPlugin {
    inherit src version nvimRequireCheck vimCommandCheck;
    pname = name;
  };
  buildNeovim = { name, src, nvimRequireCheck ? name }: neovimUtils.buildNeovimPlugin {
    inherit src version nvimRequireCheck;
    pname = name;
  };
in
# why not simple overrideAttrs?
  # - does not work for src in buildVimPlugin
  # - plugins internally depend on vimUtils.plenary-nvim and similar either way
rec {
  SchemaStore-nvim = buildVim { name = "SchemaStore.nvim"; src = inputs.SchemaStore-nvim; nvimRequireCheck = "schemastore"; };
  boole-nvim = buildVim { name = "boole.nvim"; src = inputs.boole-nvim; nvimRequireCheck = "boole"; };
  comment-nvim = (buildVim { name = "comment.nvim"; src = inputs.comment-nvim; nvimRequireCheck = "Comment"; });
  cmp-buffer = (buildVim { name = "cmp-buffer"; src = inputs.cmp-buffer; }).overrideAttrs {
    nativeBuildInputs = [ nvim-cmp ];
  };
  cmp-nvim-lsp = (buildVim { name = "cmp-nvim-lsp"; src = inputs.cmp-nvim-lsp; }).overrideAttrs {
    nativeBuildInputs = [ nvim-cmp ];
  };
  cmp-path = (buildVim { name = "cmp-path"; src = inputs.cmp-path; }).overrideAttrs {
    nativeBuildInputs = [ nvim-cmp ];
  };
  cmp_luasnip = (buildVim { name = "cmp_luasnip"; src = inputs.cmp_luasnip; }).overrideAttrs {
    nativeBuildInputs = [ nvim-cmp ];
  };
  dressing-nvim = buildVim { name = "dressing.nvim"; src = inputs.dressing-nvim; nvimRequireCheck = "dressing"; };
  friendly-snippets = (buildVim {
    name = "friendly-snippets";
    src = inputs.friendly-snippets;
    nvimRequireCheck = "luasnip.loaders.from_vscode";
  }).overrideAttrs { nativeBuildInputs = [ luasnip ]; };
  git-conflict-nvim = buildVim {
    name = "git-conflict.nvim";
    src = inputs.git-conflict-nvim;
    nvimRequireCheck = "git-conflict";
  };
  gitsigns-nvim = (buildNeovim { name = "gitsigns.nvim"; src = inputs.gitsigns-nvim; nvimRequireCheck = "gitsigns"; }).overrideAttrs {
    doInstallCheck = true;
  };
  harpoon = (buildVim { name = "harpoon"; src = inputs.harpoon; }).overrideAttrs {
    nativeBuildInputs = [ plenary-nvim ];
  };
  kanagawa-nvim = buildVim { name = "kanagawa.nvim"; src = inputs.kanagawa-nvim; nvimRequireCheck = "kanagawa"; };
  luasnip = buildVim { name = "luasnip"; src = inputs.luasnip; };
  neo-tree-nvim = buildVim { name = "neo-tree.nvim"; src = inputs.neo-tree-nvim; nvimRequireCheck = "neo-tree"; };
  neodev-nvim = buildVim { name = "neodev.nvim"; src = inputs.neodev-nvim; nvimRequireCheck = "neodev"; };
  nui-nvim = buildNeovim { name = "nui.nvim"; src = inputs.nui-nvim; nvimRequireCheck = "nui.popup"; };
  nvim-cmp = buildNeovim { name = "nvim-cmp"; src = inputs.nvim-cmp; nvimRequireCheck = "cmp"; };
  nvim-dap = buildVim { name = "nvim-dap"; src = inputs.nvim-dap; nvimRequireCheck = "dap"; };
  nvim-dap-ui = (buildVim { name = "nvim-dap-ui"; src = inputs.nvim-dap-ui; nvimRequireCheck = "dapui"; }).overrideAttrs {
    nativeBuildInputs = [ nvim-dap ];
  };
  nvim-dap-virtual-text = (buildVim {
    name = "nvim-dap-virtual-text";
    src = inputs.nvim-dap-virtual-text;
  }).overrideAttrs {
    nativeBuildInputs = [ nvim-dap ];
  };
  nvim-luaref = buildVim {
    name = "nvim-luaref";
    src = inputs.nvim-luaref;
    nvimRequireCheck = null;
  };
  nvim-navic = buildVim { name = "nvim-navic"; src = inputs.nvim-navic; };
  nvim-treesitter-context = buildVim {
    name = "nvim-treesitter-context";
    src = inputs.nvim-treesitter-context;
    nvimRequireCheck = "treesitter-context";
  };
  nvim-treesitter-textobjects = (buildVim {
    name = "nvim-treesitter-textobjects";
    src =
      inputs.nvim-treesitter-textobjects;
    nvimRequireCheck = "nvim-treesitter.textobjects";
  }).overrideAttrs {
    nativeBuildInputs = [ vimPlugins.nvim-treesitter ];
  };
  nvim-web-devicons = buildVim { name = "nvim-web-devicons"; src = inputs.nvim-web-devicons; };
  plenary-nvim = (buildNeovim { name = "plenary.nvim"; src = inputs.plenary-nvim; nvimRequireCheck = "plenary"; }).overrideAttrs {
    postPatch = ''
      sed -Ei lua/plenary/curl.lua \
          -e 's@(command\s*=\s*")curl(")@\1${curl}/bin/curl\2@'
    '';
  };
  telescope-fzf-native-nvim =
    (buildVim {
      name = "telescope-fzf-native.nvim";
      src = inputs.telescope-fzf-native-nvim;
      nvimRequireCheck = "telescope._extensions.fzf";
    }).overrideAttrs {
      buildPhase = "make";
      nativeBuildInputs = [ telescope-nvim ];
    };
  telescope-nvim = buildNeovim {
    name = "telescope.nvim";
    src = inputs.telescope-nvim;
    nvimRequireCheck = "telescope";
  };
  undotree = buildVim {
    name = "undotree";
    src = inputs.undotree;
    nvimRequireCheck = null;
    vimCommandCheck = "UndotreeToggle";
  };
  vim-fugitive = buildVim {
    name = "vim-fugitive";
    src = inputs.vim-fugitive;
    nvimRequireCheck = null;
    vimCommandCheck = "G";
  };
  which-key-nvim = buildVim { name = "which-key.nvim"; src = inputs.which-key-nvim; nvimRequireCheck = "which-key"; };
}
