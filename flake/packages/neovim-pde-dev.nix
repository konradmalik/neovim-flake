{
  lib,
  neovim-pde,
  writeShellScriptBin,
}:
let
  pkg = neovim-pde.override {
    appName = "native";
    self-contained = false;
    include-native-config = false;
    tmp-cache = true;
  };
in
(writeShellScriptBin "nvim-dev" ''
  if [[ ! $NVIM_PDE_DEV_NATIVE_CONFIG_PATH ]]; then
    echo "must set NVIM_PDE_DEV_NATIVE_CONFIG_PATH"
    exit 1
  fi

  XDG_CONFIG_DIRS="${pkg.passthru.config}:$NVIM_PDE_DEV_NATIVE_CONFIG_PATH" \
    ${lib.getExe pkg} -u $NVIM_PDE_DEV_NATIVE_CONFIG_PATH/native/init.lua
'').overrideAttrs
  {
    shellHook = ''
      export NVIM_PDE_DEV_NATIVE_CONFIG_PATH="$PWD/config"
    '';
  }
