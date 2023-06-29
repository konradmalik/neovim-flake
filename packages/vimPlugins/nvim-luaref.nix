{ vimUtils, src }:
vimUtils.buildVimPluginFrom2Nix {
  pname = "nvim-luaref";
  version = "flake-lock";
  inherit src;
  meta.homepage = "https://github.com/milisims/nvim-luaref";
}
