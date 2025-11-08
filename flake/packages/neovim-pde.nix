{
  neovim,
  neovimUtils,
  wrapNeovimUnstable,
  linkFarm,
  lib,
  config,
  plugins,
  systemDeps ? [ ],
  appName ? "neovim-pde",
  viAlias ? false,
  vimAlias ? false,
  selfContained ? true,
  devMode ? false,
}:
let
  preparedConfig = linkFarm "${appName}-config" [
    {
      name = appName;
      path = config;
    }
  ];

  extraWrapperArgs = [
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
    "'${preparedConfig}/${appName}/init.lua'"
  ]
  ++ lib.optionals (selfContained || devMode) [
    "--prefix"
    "XDG_CONFIG_DIRS"
    ":"
    "${preparedConfig}"
  ]
  ++ lib.optionals (selfContained || devMode) [
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
in
wrapNeovimUnstable neovim (
  neovimConfig
  // {
    wrapperArgs = neovimConfig.wrapperArgs ++ extraWrapperArgs;
    wrapRc = false;
  }
)
