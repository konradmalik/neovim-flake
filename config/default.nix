{
  pkgs,
  lib,
  appName,
  includeNativeConfig,
  systemLua,
}:
let
  nativeConfig = pkgs.stdenv.mkDerivation {
    name = "${appName}-native-config";
    src = ./native;
    dontBuild = true;
    installPhase = ''
      cp -r $src $out
    '';
  };
  # manually handle nix templates to avoid IFD
  binaries-lua = pkgs.callPackage ./nix/lua/pde/binaries.nix { };
  skeletons-lua = pkgs.callPackage ./nix/lua/pde/skeletons.nix { };
  system-lua = pkgs.callPackage ./nix/lua/pde/system.nix { inherit systemLua; };
in
pkgs.symlinkJoin {
  name = "${appName}-config";
  paths = [
    binaries-lua
    skeletons-lua
    system-lua
  ] ++ lib.optionals includeNativeConfig [ nativeConfig ];

  # config structure: $out/${appName}/init.lua
  # (the same as XDG_CONFIG_HOME)
  postBuild = ''
    mkdir $out/${appName}
    shopt -s extglob dotglob
    mv $out/!(${appName}) $out/${appName}
    shopt -u dotglob
  '';
}
