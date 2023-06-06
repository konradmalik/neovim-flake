{ vimUtils, src }:
vimUtils.buildVimPluginFrom2Nix {
  pname = "mini.base16";
  version = "2023-02-09";
  inherit src;
  meta.homepage = "https://github.com/echasnovski/mini.base16";
}
