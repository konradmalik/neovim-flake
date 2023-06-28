{ vimUtils, src }:
vimUtils.buildVimPluginFrom2Nix {
  pname = "j-hui";
  version = "2023-06-28";
  inherit src;
  meta.homepage = "https://github.com/j-hui/fidget.nvim";
}
