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
(
  let
    nvim-web-devicons = { plugin = pkgs.vimPlugins.nvim-web-devicons; optional = true; };
    gitsigns-nvim = { plugin = pkgs.vimPlugins.gitsigns-nvim; optional = true; dependencies = [ nvim-web-devicons ]; };
  in
  processMadePlugins (with pkgs.vimPlugins;[
    # treesitter
    (makePlugin {
      plugin = nvim-treesitter.withAllGrammars;
      optional = true;
      dependencies = [
        { plugin = nvim-treesitter-context; optional = true; }
        { plugin = nvim-treesitter-textobjects; optional = true; }
      ];
    })
    # completion
    (makePlugin {
      plugin = nvim-cmp;
      # note: for some reason cmp-related plugins cannot be optional, they won't work if true
      optional = false;
      dependencies = [
        { plugin = cmp-buffer; optional = false; }
        { plugin = cmp-nvim-lsp; optional = false; }
        { plugin = cmp-path; optional = false; }
        { plugin = cmp_luasnip; optional = false; }
        { plugin = copilot-cmp; optional = false; }
        { plugin = luasnip; optional = true; }
        { plugin = friendly-snippets; optional = true; }
        { plugin = copilot-lua; optional = true; }
      ];
    })
    # lsp
    (makePlugin {
      plugin = nvim-lspconfig;
      optional = true;
      dependencies = [
        { plugin = null-ls-nvim; optional = true; }
        { plugin = neodev-nvim; optional = true; }
        { plugin = fidget-nvim; optional = true; }
        plenary-nvim
        SchemaStore-nvim
        {
          plugin = lsp-inlayhints-nvim;
          optional = true;
        }
      ];
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
      optional = true;
      dependencies = [
        plenary-nvim
        { plugin = telescope-fzf-native-nvim; optional = true; }
      ];
    })
    # statusline
    (makePlugin {
      plugin = heirline-nvim;
      optional = true;
      dependencies = [ gitsigns-nvim nvim-web-devicons { plugin = nvim-navic; optional = true; } ];
    })
    # ui
    (makePlugin kanagawa-nvim)
    (makePlugin {
      plugin = dressing-nvim;
      optional = true;
    })
    (makePlugin
      {
        plugin = neo-tree-nvim;
        optional = true;
        dependencies = [ nvim-web-devicons plenary-nvim nui-nvim ];
      })
    # misc
    (makePlugin {
      plugin = boole-nvim;
      optional = true;
    })
    (makePlugin {
      plugin = comment-nvim;
      optional = true;
    })
    (makePlugin {
      plugin = diffview-nvim;
      optional = true;
      dependencies = [ plenary-nvim nvim-web-devicons ];
    })
    (makePlugin gitsigns-nvim)
    (makePlugin { plugin = harpoon; optional = true; })
    (makePlugin { plugin = indent-blankline-nvim; optional = true; })
    (makePlugin nvim-luaref)
    (makePlugin { plugin = undotree; optional = true; })
    (makePlugin { plugin = vim-fugitive; optional = true; })
    (makePlugin { plugin = which-key-nvim; optional = true; })
  ])
)
