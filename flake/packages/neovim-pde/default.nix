{
  neovim,
  neovimUtils,
  neovimPlugins,
  wrapNeovimUnstable,
  callPackage,
  lib,
  appName ? "neovim-pde",
  viAlias ? false,
  vimAlias ? false,
  selfContained ? true,
  includeNativeConfig ? true,
  tmpCache ? selfContained,
  systemLua ? "return {}",
}:
let
  config = callPackage ../../../config { inherit appName includeNativeConfig systemLua; };
  pluginManager = callPackage ./pluginManager.nix { inherit neovimPlugins; };
  inherit (pluginManager) plugins systemDeps;
  extraWrapperArgs =
    [
      "--set"
      "NVIM_APPNAME"
      appName
    ]
    ++ lib.optionals (systemDeps != [ ]) [
      "--suffix"
      "PATH"
      ":"
      "${lib.makeBinPath systemDeps}"
    ]
    ++ lib.optionals selfContained [
      "--add-flags"
      "-u"
      "--add-flags"
      "'${config}/${appName}/init.lua'"
      "--prefix"
      "XDG_CONFIG_DIRS"
      ":"
      "${config}"
    ]
    ++ lib.optionals tmpCache [
      "--set"
      "XDG_CACHE_HOME"
      "/tmp/${appName}-cache"
    ];

  neovimConfig = neovimUtils.makeNeovimConfig {
    inherit plugins viAlias vimAlias;
    withPython3 = false;
    withNodeJs = false;
    withRuby = false;
  };

  nvim = wrapNeovimUnstable neovim (
    neovimConfig
    // {
      wrapperArgs = neovimConfig.wrapperArgs ++ extraWrapperArgs;
      wrapRc = false;
    }
  );
in
lib.attrsets.recursiveUpdate nvim {
  passthru = {
    inherit config;
  };
}
