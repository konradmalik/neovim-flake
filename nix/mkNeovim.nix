{
  nvim,
  neovimUtils,
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
  config = ../nvim;
  preparedConfig = linkFarm "${appName}-config" [
    {
      name = appName;
      path = config;
    }
  ];

  initLua = builtins.readFile "${config}/init.lua";
  # # Wrap init.lua
  # # Bootstrap/load dev plugins
  # + lib.optionalString (devPlugins != [ ]) (
  #   ''
  #     local dev_pack_path = vim.fn.stdpath('data') .. '/site/pack/dev'
  #     local dev_plugins_dir = dev_pack_path .. '/opt'
  #     local dev_plugin_path
  #   ''
  #   + strings.concatMapStringsSep "\n" (plugin: ''
  #     dev_plugin_path = dev_plugins_dir .. '/${plugin.name}'
  #     if vim.fn.empty(vim.fn.glob(dev_plugin_path)) > 0 then
  #       vim.notify('Bootstrapping dev plugin ${plugin.name} ...', vim.log.levels.INFO)
  #       vim.cmd('!${git}/bin/git clone ${plugin.url} ' .. dev_plugin_path)
  #     end
  #     vim.cmd('packadd! ${plugin.name}')
  #   '') devPlugins

  extraWrapperArgs = [
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

  neovimConfig = neovimUtils.makeNeovimConfig {
    inherit plugins;
    viAlias = appName == "nvim";
    vimAlias = appName == "nvim";
    withPython3 = false;
    withNodeJs = false;
    withRuby = false;
  };
in
wrapNeovimUnstable nvim (
  neovimConfig
  // {
    luaRcContent = if devMode then "" else initLua;
    wrapperArgs = neovimConfig.wrapperArgs ++ extraWrapperArgs;
    wrapRc = !devMode;
  }
)
