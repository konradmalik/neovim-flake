{
  pkgs,
  lib,
  vimUtils,
  neovimUtils,
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
      # null means check all detected modules
      nvimRequireCheck ? null,
      nvimSkipModule ? null,
      vimCommandCheck ? null,
      dependencies ? [ ],
    }:
    vimUtils.buildVimPlugin {
      inherit
        dependencies
        src
        version
        nvimRequireCheck
        nvimSkipModule
        vimCommandCheck
        ;
      pname = makePname input;
    };

  buildNeovim =
    {
      input,
      src ? inputs.${input},
      version ? inputs.${input}.shortRev,
      # null means check all detected modules
      nvimRequireCheck ? null,
      nvimSkipModule ? null,
      dependencies ? [ ],
    }:
    neovimUtils.buildNeovimPlugin {
      inherit
        dependencies
        src
        version
        nvimRequireCheck
        nvimSkipModule
        ;
      pname = makePname input;
    };
in
# why not simple overrideAttrs?
# - does not work for src in buildVimPlugin
# - plugins internally depend on vimUtils.plenary-nvim and similar either way
let
  inherit (inputs'.blink-cmp.packages) blink-cmp;
  inherit (inputs'.git-conflict-nvim.packages) git-conflict-nvim;
  inherit (inputs'.incomplete-nvim.packages) incomplete-nvim;

  SchemaStore-nvim = buildVim {
    input = "SchemaStore-nvim";
  };
  boole-nvim = buildVim {
    input = "boole-nvim";
  };
  efmls-configs-nvim = buildVim {
    input = "efmls-configs-nvim";
    dependencies = [ nvim-lspconfig ];
  };
  friendly-snippets = buildVim {
    input = "friendly-snippets";
  };
  gitsigns-nvim =
    (buildNeovim {
      input = "gitsigns-nvim";
    }).overrideAttrs
      { doInstallCheck = true; };
  kanagawa-nvim = buildVim {
    input = "kanagawa-nvim";
  };
  mini-icons = buildVim {
    input = "mini-icons";
  };
  nvim-dap = buildVim {
    input = "nvim-dap";
  };
  nvim-dap-ui = buildVim {
    input = "nvim-dap-ui";
    dependencies = [
      nvim-dap
      nvim-nio
    ];
  };
  nvim-dap-virtual-text = buildVim {
    input = "nvim-dap-virtual-text";
    dependencies = [ nvim-dap ];
  };
  nvim-lspconfig = buildVim {
    input = "nvim-lspconfig";
  };
  nvim-luaref = buildVim {
    input = "nvim-luaref";
  };
  nvim-nio = buildVim {
    input = "nvim-nio";
  };
  nvim-treesitter = buildVim {
    input = "nvim-treesitter";
    nvimSkipModule = [ "nvim-treesitter._meta.parsers" ];
    dependencies = (
      let
        nvimTreesitterQueries = pkgs.linkFarm "nvim-treesitter-queries" [
          {
            name = "queries";
            path = "${inputs.nvim-treesitter}/runtime/queries";
          }
        ];
        allGrammars = pkgs.callPackage ./tree-sitter-grammars.nix {
          grammars = inputs'.tree-sitter-grammars.packages;
        };
      in
      # NOTE: nvimTreesitterQueries should be first to be earlier in runtime path. They should be preferred
      [
        nvimTreesitterQueries
        allGrammars
      ]
    );
  };

  nvim-treesitter-context = buildVim {
    input = "nvim-treesitter-context";
  };
  oil-nvim = buildVim {
    input = "oil-nvim";
  };
  plenary-nvim =
    (buildNeovim {
      input = "plenary-nvim";
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
      dependencies = [
        plenary-nvim
        telescope-nvim
      ];
    }).overrideAttrs
      { buildPhase = "make"; };
  telescope-live-grep-args-nvim = buildVim {
    input = "telescope-live-grep-args-nvim";
    dependencies = [
      plenary-nvim
      telescope-nvim
    ];
  };
  telescope-nvim = buildNeovim {
    input = "telescope-nvim";
  };
  telescope-ui-select-nvim = buildVim {
    input = "telescope-ui-select-nvim";
    dependencies = [
      telescope-nvim
      plenary-nvim
    ];
  };
  vim-fugitive = buildVim {
    input = "vim-fugitive";
    nvimRequireCheck = null;
    vimCommandCheck = "G";
  };
  which-key-nvim = buildVim {
    input = "which-key-nvim";
    nvimSkipModule = [
      "which-key.docs"
    ];
  };
in
[
  # base
  mini-icons
  plenary-nvim
  # treesitter
  {
    plugin = nvim-treesitter;
    deps = [
      nvim-treesitter-context
    ];
    systemDeps = with pkgs; [
      curl
      gnutar
      nodejs
    ];
  }
  # completion
  {
    plugin = blink-cmp;
    deps = [ friendly-snippets ];
  }
  # LSP
  efmls-configs-nvim
  nvim-lspconfig
  SchemaStore-nvim
  # DAP
  {
    plugin = nvim-dap;
    deps = [
      {
        plugin = nvim-dap-ui;
        deps = [ nvim-nio ];
      }
      {
        plugin = nvim-dap-virtual-text;
      }
    ];
  }
  # telescope
  {
    plugin = telescope-nvim;
    deps = [
      plenary-nvim
      telescope-fzf-native-nvim
      telescope-live-grep-args-nvim
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
  oil-nvim
  # snippets
  {
    plugin = incomplete-nvim;
    deps = [ friendly-snippets ];
  }
  # misc
  boole-nvim
  {
    plugin = git-conflict-nvim;
    systemDeps = [ pkgs.git ];
  }
  {
    plugin = gitsigns-nvim;
    systemDeps = [ pkgs.git ];
  }
  nvim-luaref
  {
    plugin = vim-fugitive;
    systemDeps = [ pkgs.git ];
  }
  which-key-nvim
]
