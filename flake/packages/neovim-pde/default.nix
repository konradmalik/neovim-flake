{
  neovim,
  neovimUtils,
  neovimPlugins,
  wrapNeovimUnstable,
  callPackage,
  stdenvNoCC,
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
  config = callPackage ../../../config { inherit includeNativeConfig systemLua; };

  preparedConfig = stdenvNoCC.mkDerivation {
    name = "${appName}-config";
    dontBuild = true;
    dontConfigure = true;
    src = config;
    installPhase = ''
      mkdir $out
      cp -r $src $out/${appName}
    '';
  };

  pluginsList = callPackage ./pluginsList.nix { inherit neovimPlugins; };
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
