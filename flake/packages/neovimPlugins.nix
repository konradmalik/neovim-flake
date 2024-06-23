{
  lib,
  curl,
  vimUtils,
  neovimUtils,
  all-treesitter-grammars,
  inputs,
  inputs',
}:
let
  version = "latest";
  buildVim =
    {
      name,
      src,
      nvimRequireCheck ? name,
      vimCommandCheck ? null,
      dependencies ? [ ],
    }:
    vimUtils.buildVimPlugin {
      inherit
        dependencies
        src
        version
        nvimRequireCheck
        vimCommandCheck
        ;
      pname = name;
    };
  buildNeovim =
    {
      name,
      src,
      nvimRequireCheck ? name,
      dependencies ? [ ],
    }:
    neovimUtils.buildNeovimPlugin {
      inherit
        dependencies
        src
        version
        nvimRequireCheck
        ;
      pname = name;
    };
in
# why not simple overrideAttrs?
# - does not work for src in buildVimPlugin
# - plugins internally depend on vimUtils.plenary-nvim and similar either way
rec {
  inherit (inputs'.lz-n.packages) lz-n-vimPlugin;

  SchemaStore-nvim = buildVim {
    name = "SchemaStore.nvim";
    src = inputs.SchemaStore-nvim;
    nvimRequireCheck = "schemastore";
  };
  boole-nvim = buildVim {
    name = "boole.nvim";
    src = inputs.boole-nvim;
    nvimRequireCheck = "boole";
  };
  cmp-buffer = buildVim {
    name = "cmp-buffer";
    src = inputs.cmp-buffer;
    nvimRequireCheck = "cmp_buffer";
    dependencies = [ nvim-cmp ];
  };
  cmp-nvim-lsp = buildVim {
    name = "cmp-nvim-lsp";
    src = inputs.cmp-nvim-lsp;
    nvimRequireCheck = "cmp_nvim_lsp";
    dependencies = [ nvim-cmp ];
  };
  cmp-path = buildVim {
    name = "cmp-path";
    src = inputs.cmp-path;
    nvimRequireCheck = "cmp_path";
    dependencies = [ nvim-cmp ];
  };
  cmp_luasnip = buildVim {
    name = "cmp_luasnip";
    src = inputs.cmp_luasnip;
    dependencies = [ nvim-cmp ];
  };
  friendly-snippets = buildVim {
    name = "friendly-snippets";
    src = inputs.friendly-snippets;
    nvimRequireCheck = "luasnip.loaders.from_vscode";
    dependencies = [ luasnip ];
  };
  git-conflict-nvim = buildVim {
    name = "git-conflict.nvim";
    src = inputs.git-conflict-nvim;
    nvimRequireCheck = "git-conflict";
  };
  gitsigns-nvim =
    (buildNeovim {
      name = "gitsigns.nvim";
      src = inputs.gitsigns-nvim;
      nvimRequireCheck = "gitsigns";
    }).overrideAttrs
      { doInstallCheck = true; };
  kanagawa-nvim = buildVim {
    name = "kanagawa.nvim";
    src = inputs.kanagawa-nvim;
    nvimRequireCheck = "kanagawa";
  };
  luasnip = buildVim {
    name = "luasnip";
    src = inputs.luasnip;
  };
  neo-tree-nvim = buildVim {
    name = "neo-tree.nvim";
    src = inputs.neo-tree-nvim;
    nvimRequireCheck = "neo-tree";
  };
  nui-nvim = buildNeovim {
    name = "nui.nvim";
    src = inputs.nui-nvim;
    nvimRequireCheck = "nui.popup";
  };
  nvim-cmp = buildNeovim {
    name = "nvim-cmp";
    src = inputs.nvim-cmp;
    nvimRequireCheck = "cmp";
  };
  nvim-dap = buildVim {
    name = "nvim-dap";
    src = inputs.nvim-dap;
    nvimRequireCheck = "dap";
  };
  nvim-dap-ui = buildVim {
    name = "nvim-dap-ui";
    src = inputs.nvim-dap-ui;
    nvimRequireCheck = "dapui";
    dependencies = [
      nvim-dap
      nvim-nio
    ];
  };
  nvim-dap-virtual-text = buildVim {
    name = "nvim-dap-virtual-text";
    src = inputs.nvim-dap-virtual-text;
    dependencies = [ nvim-dap ];
  };
  nvim-luaref = buildVim {
    name = "nvim-luaref";
    src = inputs.nvim-luaref;
    nvimRequireCheck = null;
  };
  nvim-nio = buildVim {
    name = "nvim-nio";
    src = inputs.nvim-nio;
    nvimRequireCheck = "nio";
  };
  nvim-treesitter =
    (buildVim {
      name = "nvim-treesitter";
      src = inputs.nvim-treesitter;
    }).overrideAttrs
      { passthru.dependencies = map neovimUtils.grammarToPlugin all-treesitter-grammars; };
  nvim-treesitter-context = buildVim {
    name = "nvim-treesitter-context";
    src = inputs.nvim-treesitter-context;
    nvimRequireCheck = "treesitter-context";
  };
  nvim-treesitter-textobjects = buildVim {
    name = "nvim-treesitter-textobjects";
    src = inputs.nvim-treesitter-textobjects;
    dependencies = [ nvim-treesitter ];
  };
  nvim-web-devicons = buildVim {
    name = "nvim-web-devicons";
    src = inputs.nvim-web-devicons;
  };
  plenary-nvim =
    (buildNeovim {
      name = "plenary.nvim";
      src = inputs.plenary-nvim;
      nvimRequireCheck = "plenary";
    }).overrideAttrs
      {
        postPatch = ''
          sed -Ei lua/plenary/curl.lua \
              -e 's@(command\s*=\s*")curl(")@\1${lib.getExe curl}\2@'
        '';
      };
  telescope-fzf-native-nvim =
    (buildVim {
      name = "telescope-fzf-native.nvim";
      src = inputs.telescope-fzf-native-nvim;
      nvimRequireCheck = "telescope._extensions.fzf";
      dependencies = [
        telescope-nvim
        plenary-nvim
      ];
    }).overrideAttrs
      { buildPhase = "make"; };
  telescope-ui-select-nvim = buildVim {
    name = "telescope-ui-select.nvim";
    src = inputs.telescope-ui-select-nvim;
    nvimRequireCheck = "telescope._extensions.ui-select";
    dependencies = [
      telescope-nvim
      plenary-nvim
    ];
  };
  telescope-nvim = buildNeovim {
    name = "telescope.nvim";
    src = inputs.telescope-nvim;
    nvimRequireCheck = "telescope";
  };
  todo-comments-nvim = buildVim {
    name = "todo-comments-nvim";
    src = inputs.todo-comments-nvim;
    nvimRequireCheck = "todo-comments";
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
  which-key-nvim = buildVim {
    name = "which-key.nvim";
    src = inputs.which-key-nvim;
    nvimRequireCheck = "which-key";
  };
}
