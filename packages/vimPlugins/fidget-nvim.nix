{ vimUtils, src }:
vimUtils.buildVimPluginFrom2Nix {
  pname = "j-hui";
  version = "flake-lock";
  inherit src;
  meta.homepage = "https://github.com/j-hui/fidget.nvim";
}
