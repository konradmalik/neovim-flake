{ pkgs, lib, appName ? "neovim-pde", viAlias ? false, vimAlias ? false, isolated ? true }:
let
  config = pkgs.callPackage ../../config { inherit appName isolated; };
  plugins = pkgs.callPackage ./plugins.nix { };
  deps = pkgs.callPackage ./deps.nix { };
  extraMakeWrapperArgs =
    [ "--set" "NVIM_APPNAME" appName ]
    ++ lib.optionals (deps != [ ])
      [ "--suffix" "PATH" ":" "${lib.makeBinPath deps}" ]
    ++ lib.optionals isolated
      [
        "--add-flags"
        "-u"
        "--add-flags"
        "'${config}/${appName}/init.lua'"
        "--prefix"
        "XDG_CONFIG_DIRS"
        ":"
        "${config}"
        "--set"
        "XDG_CACHE_HOME"
        "/tmp/${appName}-cache"
      ];

  neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
    inherit plugins viAlias vimAlias;
    withPython3 = false;
    withNodeJs = false;
    withRuby = false;
  };
in
{
  inherit config;
  nvim = (pkgs.wrapNeovimUnstable pkgs.neovim
    (neovimConfig // {
      wrapperArgs = neovimConfig.wrapperArgs ++ extraMakeWrapperArgs;
      wrapRc = false;
    }));
}
