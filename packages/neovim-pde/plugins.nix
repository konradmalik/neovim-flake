{ neovimPlugins, lib, ... }:
let
  makePlugin = plugin:
    let
      makeAttrset = p: if builtins.hasAttr "plugin" p then p else { plugin = p; };
      hasDeps = s: builtins.hasAttr "dependencies" s;
      pluginAttrset = makeAttrset plugin;
      dependencies = if hasDeps pluginAttrset then pluginAttrset.dependencies else [ ];
      dependenciesAttrsets = builtins.map makePlugin dependencies;
    in
    dependenciesAttrsets ++ [ (lib.filterAttrs (n: v: n != "dependencies") pluginAttrset) ];

  processMadePlugins = madePlugins: lib.unique (lib.flatten madePlugins);
in
processMadePlugins (with neovimPlugins; [
  # treesitter
  (makePlugin {
    plugin = nvim-treesitter;
    dependencies = [
      { plugin = nvim-treesitter-context; optional = true; }
      nvim-treesitter-textobjects
    ];
  })
  # completion
  (makePlugin {
    plugin = nvim-cmp;
    optional = true;
    dependencies = [
      { plugin = cmp-buffer; optional = true; }
      { plugin = cmp-nvim-lsp; optional = true; }
      { plugin = cmp-path; optional = true; }
      { plugin = cmp_luasnip; optional = true; }
      { plugin = luasnip; optional = true; }
      friendly-snippets
    ];
  })
  # LSP
  (makePlugin { plugin = SchemaStore-nvim; optional = true; })
  # DAP
  (makePlugin {
    plugin = nvim-dap;
    optional = true;
    dependencies = [
      {
        plugin = nvim-dap-ui;
        optional = true;
      }
      {
        plugin = nvim-dap-ui;
        optional = true;
        dependencies = [
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
    dependencies = [
      plenary-nvim
      telescope-fzf-native-nvim
    ];
  })
  # statusline
  (makePlugin nvim-web-devicons)

  # UI
  (makePlugin dressing-nvim)
  (makePlugin kanagawa-nvim)
  (makePlugin
    {
      plugin = neo-tree-nvim;
      dependencies = [ nvim-web-devicons plenary-nvim nui-nvim ];
    })
  (makePlugin {
    plugin = todo-comments-nvim;
    optional = true;
    dependencies = [ plenary-nvim ];
  })
  # misc
  (makePlugin {
    plugin = boole-nvim;
    optional = true;
  })
  (makePlugin {
    plugin = git-conflict-nvim;
    optional = true;
  })
  (makePlugin {
    plugin = gitsigns-nvim;
    optional = true;
  })
  (makePlugin harpoon)
  (makePlugin nvim-luaref)
  (makePlugin { plugin = undotree; optional = true; })
  (makePlugin vim-fugitive)
  (makePlugin which-key-nvim)
])
