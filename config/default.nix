{
  stdenvNoCC,
  callPackage,
  symlinkJoin,
  lib,
  onlyNix ? false,
}:
let
  nvim = stdenvNoCC.mkDerivation {
    name = "neovim-pde-nvim-config";
    src = ./nvim;
    dontBuild = true;
    installPhase = ''
      cp -r $src $out
    '';
  };

  nix = [
    # manually handle nix templates to avoid IFD
    (callPackage ./nix/lua/pde/binaries.nix { })
    (callPackage ./nix/lua/pde/skeletons.nix { })
  ];
in
symlinkJoin {
  name = "neovim-pde-config";
  paths = nix ++ lib.optionals (!onlyNix) [ nvim ];
}
