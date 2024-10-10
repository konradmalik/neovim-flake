{
  stdenvNoCC,
  callPackage,
  symlinkJoin,
  lib,
  onlyNix ? false,
  systemLua ? "return {}",
}:
let
  native = stdenvNoCC.mkDerivation {
    name = "neovim-pde-native-config";
    src = ./native;
    dontBuild = true;
    installPhase = ''
      cp -r $src $out
    '';
  };

  nix = [
    # manually handle nix templates to avoid IFD
    (callPackage ./nix/lua/pde/binaries.nix { })
    (callPackage ./nix/lua/pde/skeletons.nix { })
    (callPackage ./nix/lua/pde/system.nix { inherit systemLua; })
  ];
in symlinkJoin {
    name = "neovim-pde-config";
    paths = nix ++ lib.optionals (!onlyNix) [ native ];
  }
