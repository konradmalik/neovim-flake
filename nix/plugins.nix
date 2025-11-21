{
  stdenvNoCC,
  vimUtils,
  neovimUtils,
}:
{
  inputs,
  pkgs,
  lib,
}:
# notes:
# - pname matters for packadd only
# - require() is not influenced by any of the names here
let
  getSystem = attrset: attrset.${stdenvNoCC.hostPlatform.system};

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
      # other plugins
      dependencies ? [ ],
      # general packages
      runtimeDeps ? [ ],
    }:
    vimUtils.buildVimPlugin {
      inherit
        dependencies
        nvimRequireCheck
        nvimSkipModule
        runtimeDeps
        src
        version
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
      # other plugins
      dependencies ? [ ],
      # general packages
      runtimeDeps ? [ ],
    }:
    neovimUtils.buildNeovimPlugin {
      inherit
        dependencies
        nvimRequireCheck
        nvimSkipModule
        runtimeDeps
        src
        version
        ;
      pname = makePname input;
    };

  # why not simple overrideAttrs?
  # - does not work for src in buildVimPlugin
  # - plugins internally depend on vimUtils.plenary-nvim and similar either way
  plugins = rec {
    inherit (getSystem inputs.incomplete-nvim.packages) incomplete-nvim;
    inherit (getSystem inputs.git-conflict-nvim.packages) git-conflict-nvim;
    nvim-treesitter =
      (getSystem inputs.nvim-treesitter.packages).nvim-treesitter.withAllGrammars.overrideAttrs
        {
          runtimeDeps = with pkgs; [
            curl
            gnutar
            nodejs
          ];
        };

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
        runtimeDeps = [ pkgs.git ];
      }).overrideAttrs
        {
          doInstallCheck = true;
        };
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
    telescope-nvim = buildVim {
      input = "telescope-nvim";
      dependencies = [
        plenary-nvim
      ];
      runtimeDeps = with pkgs; [
        git
        fd
        fzf
        ripgrep
      ];
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
      runtimeDeps = [ pkgs.git ];
    };
    which-key-nvim = buildVim {
      input = "which-key-nvim";
      nvimSkipModule = [
        "which-key.docs"
      ];
    };
  };
in
lib.attrValues plugins
