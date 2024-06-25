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
  plugins = callPackage ./plugins.nix { inherit neovimPlugins; };
  deps = callPackage ./deps.nix { };
  extraWrapperArgs =
    [
      "--set"
      "NVIM_APPNAME"
      appName
    ]
    ++ lib.optionals (deps != [ ]) [
      "--suffix"
      "PATH"
      ":"
      "${lib.makeBinPath deps}"
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
