{ vimUtils, src }:
vimUtils.buildVimPluginFrom2Nix {
  pname = "nvim-luaref";
  version = "2022-02-17";
  inherit src;
  meta.homepage = "https://github.com/milisims/nvim-luaref";
}
