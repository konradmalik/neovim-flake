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
      # null means check all detected modules
      nvimRequireCheck ? null,
      nvimSkipModules ? null,
      vimCommandCheck ? null,
      # other plugins
      dependencies ? [ ],
      # general packages
      runtimeDeps ? [ ],
    }:
    input:
    vimUtils.buildVimPlugin {
      inherit
        dependencies
        nvimRequireCheck
        nvimSkipModules
        runtimeDeps
        vimCommandCheck
        ;
      src = inputs.${input};
      version = inputs.${input}.shortRev;
      pname = makePname input;
    };

  buildNeovim =
    {
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
    input:
    let
      lua = nvim.lua;
      pname = makePname input;
      src = inputs.${input};
      version = inputs.${input}.shortRev;

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

  inferInputs = lib.mapAttrs (name: mk: mk name);

  libs = inferInputs {
    plenary-nvim = buildNeovim {
      luaDeps = luapkgs: [ luapkgs.luassert ];
    };
  };

  plugins = inferInputs {
    incomplete-nvim = _: (getSystem inputs.incomplete-nvim.packages).incomplete-nvim;
    git-conflict-nvim = _: (getSystem inputs.git-conflict-nvim.packages).git-conflict-nvim;
    nvim-treesitter = _: (getSystem inputs.nvim-treesitter.packages).nvim-treesitter.withAllGrammars;

    SchemaStore-nvim = buildVim { };
    efmls-configs-nvim = buildVim {
      dependencies = [ plugins.nvim-lspconfig ];
    };
    friendly-snippets = buildVim { };
    gitsigns-nvim =
      input:
      (buildVim {
        runtimeDeps = [ pkgs.git ];
      } input).overrideAttrs
        {
          doInstallCheck = true;
        };
    kanagawa-nvim = buildVim { };
    mini-icons = buildVim { };
    nvim-lspconfig = buildVim { };
    nvim-treesitter-context = buildVim { };
    sops-nvim = buildVim {
      runtimeDeps = [ pkgs.sops ];
    };
    oil-nvim = buildVim { };
    telescope-fzf-native-nvim = input: (buildVim { } input).overrideAttrs { buildPhase = "make"; };
    telescope-live-grep-args-nvim = buildVim {
      dependencies = [
        libs.plenary-nvim
        plugins.telescope-nvim
      ];
    };
    telescope-nvim = buildVim {
      dependencies = [
        libs.plenary-nvim
      ];
      runtimeDeps = with pkgs; [
        fd
        ripgrep
      ];
    };
    telescope-ui-select-nvim = buildVim { };
    vim-fugitive = buildVim {
      vimCommandCheck = "G";
      runtimeDeps = [ pkgs.git ];
    };
    which-key-nvim = buildVim {
      nvimSkipModules = [
        "which-key.docs"
      ];
    };
  };
in
lib.attrValues plugins
