{ pkgs, lib, ... }:
let
  makePlugin = plugin:
    let
      makeAttrset = p: if builtins.hasAttr "plugin" p then p else { plugin = p; };
      hasDeps = s: builtins.hasAttr "dependencies" s;
      pluginAttrset = makeAttrset plugin;
      dependencies = if hasDeps pluginAttrset then pluginAttrset.dependencies else [ ];
      dependenciesAttrsets = builtins.map makeAttrset dependencies;
    in
    dependenciesAttrsets ++ [ (lib.filterAttrs (n: v: n != "dependencies") pluginAttrset) ];

  processMadePlugins = madePlugins: lib.unique (lib.flatten madePlugins);
in
processMadePlugins (with pkgs.neovimPlugins;[
  # treesitter
  (makePlugin {
    plugin = nvim-treesitter.withAllGrammars;
    dependencies = [
      nvim-treesitter-context
      nvim-treesitter-textobjects
    ];
  })
  # completion
  (makePlugin {
    plugin = nvim-cmp;
    dependencies = [
      cmp-buffer
      cmp-nvim-lsp
      cmp-path
      cmp_luasnip
      { plugin = copilot-cmp; optional = true; }
      { plugin = copilot-lua; optional = true; }
      luasnip
      friendly-snippets
    ];
  })
  # lsp
  (makePlugin { plugin = neodev-nvim; optional = true; })
  (makePlugin { plugin = SchemaStore-nvim; optional = true; })
  (makePlugin {
    plugin = csharpls-extended-lsp-nvim;
    optional = true;
  })
  (makePlugin {
    plugin = omnisharp-extended-lsp-nvim;
    optional = true;
  })
  # dap
  (makePlugin {
    plugin = nvim-dap;
    optional = true;
    dependencies = [
      {
        plugin = nvim-dap-ui;
        optional = true;
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
  (makePlugin {
    plugin = heirline-nvim;
    dependencies = [ gitsigns-nvim nvim-web-devicons nvim-navic ];
  })
  # ui
  (makePlugin kanagawa-nvim)
  (makePlugin dressing-nvim)
  (makePlugin
    {
      plugin = neo-tree-nvim;
      dependencies = [ nvim-web-devicons plenary-nvim nui-nvim ];
    })
  # misc
  (makePlugin boole-nvim)
  (makePlugin comment-nvim)
  (makePlugin git-conflict-nvim)
  (makePlugin gitsigns-nvim)
  (makePlugin harpoon)
  (makePlugin nvim-luaref)
  (makePlugin { plugin = undotree; optional = true; })
  (makePlugin vim-fugitive)
  (makePlugin which-key-nvim)
])
