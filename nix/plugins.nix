{
  inputs,
  pkgs,
  nvim,
}:
# notes:
# - pname matters for packadd only
# - require() is not influenced by any of the names here
let
  inherit (pkgs) lib vimUtils neovimUtils;

  getSystem = attrset: attrset.${pkgs.stdenv.hostPlatform.system};

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
      nvimSkipModules ? null,
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
        nvimSkipModules
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
      nvimSkipModules ? null,
      # other plugins
      dependencies ? [ ],
      # general packages
      runtimeDeps ? [ ],
      # luarocks dependencies declared in the plugin's rockspec; given the lua
      # package set, return the list of packages to satisfy them.
      luaDeps ? (_: [ ]),
    }:
    let
      lua = nvim.lua;
      pname = makePname input;

      # rockspecs are named e.g. plenary.nvim-scm-1.rockspec, not matching our
      # git-rev version, so locate the bundled rockspec explicitly and derive
      # the luarocks version (e.g. scm-1) from its filename.
      rockspecFilename =
        let
          rockspecs = builtins.filter (lib.strings.hasSuffix ".rockspec") (
            builtins.attrNames (builtins.readDir src)
          );
        in
        if rockspecs == [ ] then
          throw "buildNeovim: no .rockspec found in source of '${pname}'; use buildVim for plugins without a rockspec"
        else
          builtins.head rockspecs;
      rockspecVersion = lib.removeSuffix ".rockspec" (lib.removePrefix "${pname}-" rockspecFilename);

      luaAttr = lua.pkgs.buildLuarocksPackage {
        inherit
          src
          version
          pname
          rockspecFilename
          rockspecVersion
          ;
        propagatedBuildInputs = luaDeps lua.pkgs;
      };
    in
    neovimUtils.buildNeovimPlugin {
      inherit
        luaAttr
        dependencies
        nvimRequireCheck
        nvimSkipModules
        runtimeDeps
        ;
    };

  libs = {
    plenary-nvim = buildNeovim {
      input = "plenary-nvim";
      luaDeps = luapkgs: [ luapkgs.luassert ];
    };
  };
in
lib.attrValues rec {
  inherit (getSystem inputs.incomplete-nvim.packages) incomplete-nvim;
  inherit (getSystem inputs.git-conflict-nvim.packages) git-conflict-nvim;
  nvim-treesitter =
    let
      ts = pkgs.vimPlugins.nvim-treesitter;
      parsers = lib.filter lib.isDerivation (lib.attrValues ts.parsers);
      queries = lib.filter lib.isDerivation (lib.attrValues ts.queries);
    in
    pkgs.symlinkJoin {
      name = "nvim-treesitter-parsers-and-queries";
      paths = parsers ++ queries;
    };

  SchemaStore-nvim = buildVim {
    input = "SchemaStore-nvim";
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
  nvim-lspconfig = buildVim {
    input = "nvim-lspconfig";
  };
  nvim-treesitter-context = buildVim {
    input = "nvim-treesitter-context";
  };
  oil-nvim = buildVim {
    input = "oil-nvim";
  };
  telescope-fzf-native-nvim =
    (buildVim {
      input = "telescope-fzf-native-nvim";
    }).overrideAttrs
      { buildPhase = "make"; };
  telescope-live-grep-args-nvim = buildVim {
    input = "telescope-live-grep-args-nvim";
    dependencies = [
      libs.plenary-nvim
      telescope-nvim
    ];
  };
  telescope-nvim = buildVim {
    input = "telescope-nvim";
    dependencies = [
      libs.plenary-nvim
    ];
    runtimeDeps = with pkgs; [
      fd
      ripgrep
    ];
  };
  telescope-ui-select-nvim = buildVim {
    input = "telescope-ui-select-nvim";
  };
  vim-fugitive = buildVim {
    input = "vim-fugitive";
    vimCommandCheck = "G";
    runtimeDeps = [ pkgs.git ];
  };
  which-key-nvim = buildVim {
    input = "which-key-nvim";
    nvimSkipModules = [
      "which-key.docs"
    ];
  };
}
