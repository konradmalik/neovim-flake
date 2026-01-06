{
  nvim,
  neovimUtils,
  git,
  stdenv,
  sqlite,
  wrapNeovimUnstable,
  linkFarm,
  lib,
}:
{
  plugins ? [ ],
  extraPackages ? [ ],
  appName ? "nvim",
  # plugins added via vim.pack, useful for plugin development
  # schema: { name = <name>, uri = <any git-compatible uri> }
  devPlugins ? [ ],
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

  initLua =
    builtins.readFile ../nvim/init.lua
    + lib.optionalString (devPlugins != [ ]) (
      let
        specs = lib.concatMapStringsSep ", " (
          plugin: "{ name = '${plugin.name}', src = '${plugin.uri}'}"
        ) devPlugins;
        names = lib.concatMapStringsSep ", " (plugin: "'${plugin.name}'") devPlugins;
      in
      # lua
      ''
        vim.pack.add({ ${specs} }, { confirm = false, load = true })
        vim.pack.update({ ${names} }, { force = true })
      ''
    );

  # sqlite is required by some plugins, just add it always
  # git is required by vim.pack
  externalPackages = extraPackages ++ [ sqlite ] ++ lib.optionals (devPlugins != [ ]) [ git ];

  extraWrapperArgs =
    let
      sqliteLibExt = stdenv.hostPlatform.extensions.sharedLibrary;
      sqliteLibPath = "${sqlite.out}/lib/libsqlite3${sqliteLibExt}";
    in
    [
      "--set"
      "NVIM_APPNAME"
      appName
      "--set"
      "LIBSQLITE_CLIB_PATH"
      "${sqliteLibPath}"
      "--set"
      "LIBSQLITE"
      "${sqliteLibPath}"
    ]
    ++ lib.optionals (extraPackages != [ ]) [
      "--suffix"
      "PATH"
      ":"
      "${lib.makeBinPath externalPackages}"
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

  neovimConfig = neovimUtils.makeNeovimConfig {
    inherit plugins;
    viAlias = appName == "nvim";
    vimAlias = appName == "nvim";
    withPython3 = false;
    withNodeJs = false;
    withRuby = false;
  };

  nvim-wrapped = wrapNeovimUnstable nvim (
    neovimConfig
    // {
      luaRcContent = if devMode then "" else initLua;
      wrapperArgs = neovimConfig.wrapperArgs ++ extraWrapperArgs;
      wrapRc = !devMode;
    }
  );

  isCustomAppName = appName != null && appName != "nvim";
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
