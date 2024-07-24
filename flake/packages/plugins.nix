{
  pkgs,
  lib,
  vimUtils,
  neovimUtils,
  all-treesitter-grammars,
  inputs,
  inputs',
}:
# notes:
# - pname matters for packadd only
# - require() is not influenced by any of the names here
let
  makePname =
    str:
    if lib.strings.hasSuffix "-nvim" str then
      builtins.replaceStrings [ "-nvim" ] [ ".nvim" ] str
    else if lib.strings.hasSuffix "-vim" str then
      builtins.replaceStrings [ "-vim" ] [ ".vim" ] str
    else
      str;

  buildVim =
    {
      input,
      src ? inputs.${input},
      version ? inputs.${input}.shortRev,
      nvimRequireCheck ? input,
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
      pname = makePname input;
    };

  buildNeovim =
    {
      input,
      src ? inputs.${input},
      version ? inputs.${input}.shortRev,
      nvimRequireCheck ? input,
      dependencies ? [ ],
    }:
    neovimUtils.buildNeovimPlugin {
      inherit
        dependencies
        src
        version
        nvimRequireCheck
        ;
      pname = makePname input;
    };
in
# why not simple overrideAttrs?
# - does not work for src in buildVimPlugin
# - plugins internally depend on vimUtils.plenary-nvim and similar either way
let
  inherit (inputs'.lz-n.packages) lz-n-vimPlugin;
  SchemaStore-nvim = buildVim {
    input = "SchemaStore-nvim";
    nvimRequireCheck = "schemastore";
  };
  boole-nvim = buildVim {
    input = "boole-nvim";
    nvimRequireCheck = "boole";
  };
  cmp-buffer = buildVim {
    input = "cmp-buffer";
    nvimRequireCheck = "cmp_buffer";
    dependencies = [ nvim-cmp ];
  };
  cmp-nvim-lsp = buildVim {
    input = "cmp-nvim-lsp";
    nvimRequireCheck = "cmp_nvim_lsp";
    dependencies = [ nvim-cmp ];
  };
  cmp-path = buildVim {
    input = "cmp-path";
    nvimRequireCheck = "cmp_path";
    dependencies = [ nvim-cmp ];
  };
  cmp_luasnip = buildVim {
    input = "cmp_luasnip";
    dependencies = [ nvim-cmp ];
  };
  friendly-snippets = buildVim {
    input = "friendly-snippets";
    nvimRequireCheck = "luasnip.loaders.from_vscode";
    dependencies = [ luasnip ];
  };
  git-conflict-nvim = buildVim {
    input = "git-conflict-nvim";
    nvimRequireCheck = "git-conflict";
  };
  gitsigns-nvim =
    (buildNeovim {
      input = "gitsigns-nvim";
      nvimRequireCheck = "gitsigns";
    }).overrideAttrs
      { doInstallCheck = true; };
  kanagawa-nvim = buildVim {
    input = "kanagawa-nvim";
    nvimRequireCheck = "kanagawa";
  };
  luasnip = buildVim { input = "luasnip"; };
  neo-tree-nvim = buildVim {
    input = "neo-tree-nvim";
    nvimRequireCheck = "neo-tree";
  };
  nui-nvim = buildNeovim {
    input = "nui-nvim";
    nvimRequireCheck = "nui.popup";
  };
  nvim-cmp = buildNeovim {
    input = "nvim-cmp";
    nvimRequireCheck = "cmp";
  };
  nvim-dap = buildVim {
    input = "nvim-dap";
    nvimRequireCheck = "dap";
  };
  nvim-dap-ui = buildVim {
    input = "nvim-dap-ui";
    nvimRequireCheck = "dapui";
    dependencies = [
      nvim-dap
      nvim-nio
    ];
  };
  nvim-dap-virtual-text = buildVim {
    input = "nvim-dap-virtual-text";
    dependencies = [ nvim-dap ];
  };
  nvim-luaref = buildVim {
    input = "nvim-luaref";
    nvimRequireCheck = null;
  };
  nvim-nio = buildVim {
    input = "nvim-nio";
    nvimRequireCheck = "nio";
  };
  nvim-treesitter = (buildVim { input = "nvim-treesitter"; }).overrideAttrs {
    passthru.dependencies = map neovimUtils.grammarToPlugin all-treesitter-grammars;
  };
  nvim-treesitter-context = buildVim {
    input = "nvim-treesitter-context";
    nvimRequireCheck = "treesitter-context";
  };
  nvim-treesitter-textobjects = buildVim {
    input = "nvim-treesitter-textobjects";
    dependencies = [ nvim-treesitter ];
  };
  nvim-web-devicons = buildVim { input = "nvim-web-devicons"; };
  plenary-nvim =
    (buildNeovim {
      input = "plenary-nvim";
      nvimRequireCheck = "plenary";
    }).overrideAttrs
      {
        postPatch = ''
          sed -Ei lua/plenary/curl.lua \
              -e 's@(command\s*=\s*")curl(")@\1${lib.getExe pkgs.curl}\2@'
        '';
      };
  telescope-fzf-native-nvim =
    (buildVim {
      input = "telescope-fzf-native-nvim";
      nvimRequireCheck = "telescope._extensions.fzf";
      dependencies = [
        telescope-nvim
        plenary-nvim
      ];
    }).overrideAttrs
      { buildPhase = "make"; };
  telescope-ui-select-nvim = buildVim {
    input = "telescope-ui-select-nvim";
    nvimRequireCheck = "telescope._extensions.ui-select";
    dependencies = [
      telescope-nvim
      plenary-nvim
    ];
  };
  telescope-nvim = buildNeovim {
    input = "telescope-nvim";
    nvimRequireCheck = "telescope";
  };
  todo-comments-nvim = buildVim {
    input = "todo-comments-nvim";
    nvimRequireCheck = "todo-comments";
  };
  undotree = buildVim {
    input = "undotree";
    nvimRequireCheck = null;
    vimCommandCheck = "UndotreeToggle";
  };
  vim-fugitive = buildVim {
    input = "vim-fugitive";
    nvimRequireCheck = null;
    vimCommandCheck = "G";
  };
  which-key-nvim = buildVim {
    input = "which-key-nvim";
    nvimRequireCheck = "which-key";
  };
in
[
  # base
  nvim-web-devicons
  plenary-nvim
  lz-n-vimPlugin
  # treesitter
  {
    plugin = nvim-treesitter;
    deps = [
      {
        plugin = nvim-treesitter-context;
        optional = true;
      }
      nvim-treesitter-textobjects
    ];
  }
  # completion
  {
    plugin = nvim-cmp;
    optional = true;
    deps = [
      {
        plugin = cmp-buffer;
        optional = true;
      }
      {
        plugin = cmp-nvim-lsp;
        optional = true;
      }
      {
        plugin = cmp-path;
        optional = true;
      }
      {
        plugin = cmp_luasnip;
        optional = true;
        deps = [
          {
            plugin = luasnip;
            optional = true;
            deps = [ friendly-snippets ];
          }
        ];
      }
    ];
  }
  # LSP
  {
    plugin = SchemaStore-nvim;
    optional = true;
  }
  # DAP
  {
    plugin = nvim-dap;
    optional = true;
    deps = [
      {
        plugin = nvim-dap-ui;
        optional = true;
        deps = [
          {
            plugin = nvim-nio;
            optional = true;
          }
        ];
      }
      {
        plugin = nvim-dap-virtual-text;
        optional = true;
      }
    ];
  }
  # telescope
  {
    plugin = telescope-nvim;
    deps = [
      plenary-nvim
      telescope-fzf-native-nvim
      telescope-ui-select-nvim
    ];
    systemDeps = [
      pkgs.git
      pkgs.fd
      pkgs.fzf
      pkgs.ripgrep
    ];
  }
  # UI
  kanagawa-nvim
  {
    plugin = neo-tree-nvim;
    deps = [
      nvim-web-devicons
      plenary-nvim
      nui-nvim
    ];
    systemDeps = [ pkgs.git ];
  }
  {
    plugin = todo-comments-nvim;
    optional = true;
    deps = [ plenary-nvim ];
  }
  # misc
  {
    plugin = boole-nvim;
    optional = true;
  }
  {
    plugin = git-conflict-nvim;
    optional = true;
    systemDeps = [ pkgs.git ];
  }
  {
    plugin = gitsigns-nvim;
    optional = true;
    systemDeps = [ pkgs.git ];
  }
  nvim-luaref
  {
    plugin = undotree;
    optional = true;
  }
  {
    plugin = vim-fugitive;
    systemDeps = [ pkgs.git ];
  }
  which-key-nvim
]
