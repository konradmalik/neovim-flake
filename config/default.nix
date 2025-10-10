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
    (callPackage ./nix/lua/pde/debugpy.nix { })
    (callPackage ./nix/lua/pde/skeletons.nix { })
    # # if we don't use TSInstall, then those are not included in the runtime path
    # "${inputs.nvim-treesitter}/runtime"
  ];
in
symlinkJoin {
  name = "neovim-pde-config";
  paths = nix ++ lib.optionals (!onlyNix) [ nvim ];
}
