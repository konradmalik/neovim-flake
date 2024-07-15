{
  neovim,
  neovimUtils,
  wrapNeovimUnstable,
  callPackage,
  stdenvNoCC,
  lib,
  nvimConfig,
  pluginsList,
  appName ? "neovim-pde",
  viAlias ? false,
  vimAlias ? false,
  selfContained ? true,
  tmpCache ? selfContained,
  prependXdgConfig ? selfContained,
}:
let
  preparedConfig = stdenvNoCC.mkDerivation {
    name = "${appName}-config";
    dontBuild = true;
    dontConfigure = true;
    src = nvimConfig;
    installPhase = ''
      mkdir $out
      cp -r $src $out/${appName}
    '';
  };

  pluginsPack = callPackage ./pluginManager.nix { inherit pluginsList; };
  inherit (pluginsPack) plugins systemDeps;
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
      "'${preparedConfig}/${appName}/init.lua'"
    ]
    ++ lib.optionals prependXdgConfig [
      "--prefix"
      "XDG_CONFIG_DIRS"
      ":"
      "${preparedConfig}"
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

in
wrapNeovimUnstable neovim (
  neovimConfig
  // {
    wrapperArgs = neovimConfig.wrapperArgs ++ extraWrapperArgs;
    wrapRc = false;
  }
)
