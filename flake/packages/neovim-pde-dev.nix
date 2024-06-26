{
  lib,
  writeShellScriptBin,
  neovim-pde,
  nvimConfig,
}:
let
  devConfig = nvimConfig.override { includeNativeConfig = false; };
  pkg = neovim-pde.override {
    appName = "native";
    selfContained = false;
    tmpCache = true;
    config = devConfig;
  };
in
(writeShellScriptBin "nvim-dev" ''
  if [[ ! $NVIM_PDE_DEV_NATIVE_CONFIG_PATH ]]; then
    echo "must set NVIM_PDE_DEV_NATIVE_CONFIG_PATH"
    exit 1
  fi

  XDG_CONFIG_DIRS="${devConfig}:$NVIM_PDE_DEV_NATIVE_CONFIG_PATH" \
    ${lib.getExe pkg} -u $NVIM_PDE_DEV_NATIVE_CONFIG_PATH/native/init.lua
'').overrideAttrs
  {
    shellHook = ''
      export NVIM_PDE_DEV_NATIVE_CONFIG_PATH="$PWD/config"
    '';
  }
