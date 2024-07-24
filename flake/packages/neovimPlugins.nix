{
  lib,
  curl,
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

  normalizeName = lib.replaceStrings [ "." ] [ "-" ];

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

  makeNeovimPlugins =
    l:
    builtins.listToAttrs (
      builtins.map (x: {
        name = normalizeName x.pname;
        value = x;
      }) l
    );
in
# why not simple overrideAttrs?
# - does not work for src in buildVimPlugin
# - plugins internally depend on vimUtils.plenary-nvim and similar either way
let
  neovimPlugins =
    {
      inherit (inputs'.lz-n.packages) lz-n-vimPlugin;
    }
    // (makeNeovimPlugins [
      (buildVim {
        input = "SchemaStore-nvim";
        nvimRequireCheck = "schemastore";
      })
      (buildVim {
        input = "boole-nvim";
        nvimRequireCheck = "boole";
      })
      (buildVim {
        input = "cmp-buffer";
        nvimRequireCheck = "cmp_buffer";
        dependencies = [ neovimPlugins.nvim-cmp ];
      })
      (buildVim {
        input = "cmp-nvim-lsp";
        nvimRequireCheck = "cmp_nvim_lsp";
        dependencies = [ neovimPlugins.nvim-cmp ];
      })
      (buildVim {
        input = "cmp-path";
        nvimRequireCheck = "cmp_path";
        dependencies = [ neovimPlugins.nvim-cmp ];
      })
      (buildVim {
        input = "cmp_luasnip";
        dependencies = [ neovimPlugins.nvim-cmp ];
      })
      (buildVim {
        input = "friendly-snippets";
        nvimRequireCheck = "luasnip.loaders.from_vscode";
        dependencies = [ neovimPlugins.luasnip ];
      })
      (buildVim {
        input = "git-conflict-nvim";
        nvimRequireCheck = "git-conflict";
      })
      (
        (buildNeovim {
          input = "gitsigns-nvim";
          nvimRequireCheck = "gitsigns";
        }).overrideAttrs
        { doInstallCheck = true; }
      )
      (buildVim {
        input = "kanagawa-nvim";
        nvimRequireCheck = "kanagawa";
      })
      (buildVim { input = "luasnip"; })
      (buildVim {
        input = "neo-tree-nvim";
        nvimRequireCheck = "neo-tree";
      })
      (buildNeovim {
        input = "nui-nvim";
        nvimRequireCheck = "nui.popup";
      })
      (buildNeovim {
        input = "nvim-cmp";
        nvimRequireCheck = "cmp";
      })
      (buildVim {
        input = "nvim-dap";
        nvimRequireCheck = "dap";
      })
      (buildVim {
        input = "nvim-dap-ui";
        nvimRequireCheck = "dapui";
        dependencies = [
          neovimPlugins.nvim-dap
          neovimPlugins.nvim-nio
        ];
      })
      (buildVim {
        input = "nvim-dap-virtual-text";
        dependencies = [ neovimPlugins.nvim-dap ];
      })
      (buildVim {
        input = "nvim-luaref";
        nvimRequireCheck = null;
      })
      (buildVim {
        input = "nvim-nio";
        nvimRequireCheck = "nio";
      })
      ((buildVim { input = "nvim-treesitter"; }).overrideAttrs {
        passthru.dependencies = map neovimUtils.grammarToPlugin all-treesitter-grammars;
      })
      (buildVim {
        input = "nvim-treesitter-context";
        nvimRequireCheck = "treesitter-context";
      })
      (buildVim {
        input = "nvim-treesitter-textobjects";
        dependencies = [ neovimPlugins.nvim-treesitter ];
      })
      (buildVim { input = "nvim-web-devicons"; })
      (
        (buildNeovim {
          input = "plenary-nvim";
          nvimRequireCheck = "plenary";
        }).overrideAttrs
        {
          postPatch = ''
            sed -Ei lua/plenary/curl.lua \
                -e 's@(command\s*=\s*")curl(")@\1${lib.getExe curl}\2@'
          '';
        }
      )
      (
        (buildVim {
          input = "telescope-fzf-native-nvim";
          nvimRequireCheck = "telescope._extensions.fzf";
          dependencies = [
            neovimPlugins.telescope-nvim
            neovimPlugins.plenary-nvim
          ];
        }).overrideAttrs
        { buildPhase = "make"; }
      )
      (buildVim {
        input = "telescope-ui-select-nvim";
        nvimRequireCheck = "telescope._extensions.ui-select";
        dependencies = [
          neovimPlugins.telescope-nvim
          neovimPlugins.plenary-nvim
        ];
      })
      (buildNeovim {
        input = "telescope-nvim";
        nvimRequireCheck = "telescope";
      })
      (buildVim {
        input = "todo-comments-nvim";
        nvimRequireCheck = "todo-comments";
      })
      (buildVim {
        input = "undotree";
        nvimRequireCheck = null;
        vimCommandCheck = "UndotreeToggle";
      })
      (buildVim {
        input = "vim-fugitive";
        nvimRequireCheck = null;
        vimCommandCheck = "G";
      })
      (buildVim {
        input = "which-key-nvim";
        nvimRequireCheck = "which-key";
      })
    ]);
in
neovimPlugins
