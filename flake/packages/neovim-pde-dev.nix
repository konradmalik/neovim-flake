{
  lib,
  writeShellScriptBin,
  neovim-pde,
  config,
}:
let
  devConfig = config.override { onlyNix = true; };
  pkg = neovim-pde.override {
    # this is a hack to load everything in 'native' folder
    appName = "native";
    selfContained = false;
    devMode = true;
    config = devConfig;
  };
in
(writeShellScriptBin "nvim-dev" ''
  if [[ ! $NVIM_PDE_DEV_NATIVE_CONFIG_PATH ]]; then
    echo "must set NVIM_PDE_DEV_NATIVE_CONFIG_PATH"
    exit 1
  fi

  XDG_CONFIG_DIRS="${devConfig}:$NVIM_PDE_DEV_NATIVE_CONFIG_PATH" \
    ${lib.getExe pkg} -u $NVIM_PDE_DEV_NATIVE_CONFIG_PATH/native/init.lua "$@"
'').overrideAttrs
  {
    shellHook = ''
      export NVIM_PDE_DEV_NATIVE_CONFIG_PATH="$PWD/config"
    '';
  }
