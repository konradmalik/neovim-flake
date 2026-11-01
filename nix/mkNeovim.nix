{
  nvim,
  wrapNeovimUnstable,
  linkFarm,
  lib,
}:
{
  plugins ? [ ],
  extraPackages ? [ ],
  appName ? "nvim",
  devMode ? false,
}:
let
  # config without init.lua, because we explicitly load init.lua with luaRcContent
  configDir =
    let
      src = ../nvim;
    in
    lib.cleanSourceWith {
      inherit src;
      name = "${appName}-config-dir";
      filter = fpath: type: !lib.hasSuffix "/nvim/init.lua" fpath;
    };

  # prepend config with appName for it to be loadable from XDG_CONFIG_DIRS
  preparedConfig = linkFarm "${appName}-config" [
    {
      name = appName;
      path = configDir;
    }
  ];

  userInitLua = builtins.readFile ../nvim/init.lua;

  # in dev mode init.lua is read live from the linked config dir, but still through
  # the generated rc so we keep what the wrapper adds (provider settings etc.)
  devInitLua = # lua
    ''
      dofile(vim.fn.stdpath("config") .. "/init.lua")
    '';

  wrapperArgs = [
    "--set"
    "NVIM_APPNAME"
    appName
  ]
  ++ lib.optionals (extraPackages != [ ]) [
    "--suffix"
    "PATH"
    ":"
    "${lib.makeBinPath extraPackages}"
  ]
  ++ lib.optionals (!devMode) [
    "--prefix"
    "XDG_CONFIG_DIRS"
    ":"
    "${preparedConfig}"
  ]
  ++ lib.optionals devMode [
    "--set"
    "XDG_CACHE_HOME"
    "/tmp/${appName}-cache"
  ];

  nvim-wrapped = wrapNeovimUnstable nvim {
    inherit plugins wrapperArgs;
    # tells the dev and release wrappers apart in build logs
    extraName = lib.optionalString devMode "-dev";
    luaRcContent = if devMode then devInitLua else userInitLua;
  };

  isCustomAppName = appName != "nvim";
in
nvim-wrapped.overrideAttrs (oa: {
  buildPhase =
    oa.buildPhase
    # If a custom NVIM_APPNAME has been set, rename the `nvim` binary
    + lib.optionalString isCustomAppName ''
      mv $out/bin/nvim $out/bin/${lib.escapeShellArg appName}
    '';
  meta.mainProgram = if isCustomAppName then appName else oa.meta.mainProgram;
})
