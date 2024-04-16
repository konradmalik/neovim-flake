{ pkgs, lib, appName, include-native-config }:
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
  binaries-lua = pkgs.callPackage ./nix/lua/konrad/binaries.nix { };
  skeletons-lua = pkgs.callPackage ./nix/lua/konrad/skeletons.nix { };
in
pkgs.symlinkJoin {
  name = "${appName}-config";
  paths = [
    binaries-lua
    skeletons-lua
  ] ++ lib.optionals include-native-config
    [ nativeConfig ];

  # config structure: $out/${appName}/init.lua
  # (the same as XDG_CONFIG_HOME)
  postBuild = ''
    mkdir $out/${appName}
    shopt -s extglob dotglob
    mv $out/!(${appName}) $out/${appName}
    shopt -u dotglob
  '';
}
