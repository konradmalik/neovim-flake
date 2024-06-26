{
  stdenvNoCC,
  callPackage,
  symlinkJoin,
  lib,
  includeNativeConfig ? true,
  systemLua ? "return {}",
}:
let
  nativeConfig = stdenvNoCC.mkDerivation {
    name = "neovim-pde-native-config";
    src = ./native;
    dontBuild = true;
    installPhase = ''
      cp -r $src $out
    '';
  };
  # manually handle nix templates to avoid IFD
  binaries-lua = callPackage ./nix/lua/pde/binaries.nix { };
  skeletons-lua = callPackage ./nix/lua/pde/skeletons.nix { };
  system-lua = callPackage ./nix/lua/pde/system.nix { inherit systemLua; };
in
symlinkJoin {
  name = "neovim-pde-config";
  paths = [
    binaries-lua
    skeletons-lua
    system-lua
  ] ++ lib.optionals includeNativeConfig [ nativeConfig ];
}
