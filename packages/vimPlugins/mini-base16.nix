{ vimUtils, src }:
vimUtils.buildVimPluginFrom2Nix {
  pname = "mini.base16";
  version = "flake-lock";
  inherit src;
  meta.homepage = "https://github.com/echasnovski/mini.base16";
}
