{ pkgs, lib, appName, self-contained }:
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
  skeletons-lua = pkgs.callPackage ./nix/lua/konrad/skeletons.nix { inherit nativeConfig; };
in
pkgs.symlinkJoin {
  name = "${appName}-config";
  paths = [
    nativeConfig
    binaries-lua
    skeletons-lua
  ];

  # config structure:
  # - if self-contained is false, then $out/init.lua. This is for home-manager
  # - if self-contained is true, then $out/${appName}/init.lua. This is for 'nix run .' etc where we override XDG_CONFIG_HOME
  #   and the expected structure is the same as XDG_CONFIG_HOME
  # postBuild below runs if self-contained and it's purpose is to create XDG_CONFIG_HOME-like folder structure
  postBuild = lib.optionalString self-contained ''
    mkdir $out/${appName}
    shopt -s extglob dotglob
    mv $out/!(${appName}) $out/${appName}
    shopt -u dotglob
  '';
}
