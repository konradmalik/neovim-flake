{
  neovimPlugins,
  lib,
  git,
  fd,
  fzf,
  ripgrep,
  ...
}:
let
  makePlugin =
    p:
    let
      pluginAttrset = if p ? plugin then p else { plugin = p; };
      deps = if pluginAttrset ? deps then pluginAttrset.deps else [ ];
      depsAttrsets = builtins.map makePlugin deps;
    in
    depsAttrsets ++ [ (lib.filterAttrs (n: v: n != "deps") pluginAttrset) ];

  process =
    madePlugins:
    let
      flat = lib.unique (lib.flatten madePlugins);
      plugins = builtins.map (lib.filterAttrs (n: v: n != "systemDeps")) flat;
      systemDeps = builtins.map(a: if a ? systemDeps then a.systemDeps else []) flat;
    in
    {
      inherit plugins;
      systemDeps = lib.unique (lib.flatten systemDeps);
    };
in
process (
  with neovimPlugins;
  [
    # treesitter
    (makePlugin {
      plugin = nvim-treesitter;
      deps = [
        {
          plugin = nvim-treesitter-context;
          optional = true;
        }
        nvim-treesitter-textobjects
      ];
    })
    # completion
    (makePlugin {
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
        }
        {
          plugin = luasnip;
          optional = true;
        }
        friendly-snippets
      ];
    })
    # LSP
    (makePlugin {
      plugin = SchemaStore-nvim;
      optional = true;
    })
    # DAP
    (makePlugin {
      plugin = nvim-dap;
      optional = true;
      deps = [
        {
          plugin = nvim-dap-ui;
          optional = true;
        }
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
    })
    # telescope
    (makePlugin {
      plugin = telescope-nvim;
      deps = [
        plenary-nvim
        telescope-fzf-native-nvim
        telescope-ui-select-nvim
      ];
      systemDeps = [
        git
        fd
        fzf
        ripgrep
      ];
    })
    # statusline
    (makePlugin nvim-web-devicons)

    # UI
    (makePlugin kanagawa-nvim)
    (makePlugin {
      plugin = neo-tree-nvim;
      deps = [
        nvim-web-devicons
        plenary-nvim
        nui-nvim
      ];
      systemDeps = [ git ];
    })
    (makePlugin {
      plugin = todo-comments-nvim;
      optional = true;
      deps = [ plenary-nvim ];
    })
    # misc
    lz-n-vimPlugin
    (makePlugin {
      plugin = boole-nvim;
      optional = true;
    })
    (makePlugin {
      plugin = git-conflict-nvim;
      optional = true;
      systemDeps = [ git ];
    })
    (makePlugin {
      plugin = gitsigns-nvim;
      optional = true;
      systemDeps = [ git ];
    })
    (makePlugin nvim-luaref)
    (makePlugin {
      plugin = undotree;
      optional = true;
    })
    (makePlugin {
      plugin = vim-fugitive;
      systemDeps = [ git ];
    })
    (makePlugin which-key-nvim)
  ]
)
