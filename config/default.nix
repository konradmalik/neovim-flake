{
  callPackage,
  symlinkJoin,
  lib,
  onlyNix ? false,
}:
let
  nix = [
    # manually handle nix templates to avoid IFD
    (callPackage ./nix/lua/pde/debugpy.nix { })
    (callPackage ./nix/lua/pde/skeletons.nix { })
  ];
in
symlinkJoin {
  name = "neovim-pde-config";
  paths = nix ++ lib.optionals (!onlyNix) [ ./nvim ];
}
