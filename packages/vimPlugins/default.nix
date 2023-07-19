{ vimUtils, inputs }:
{
  fidget-nvim = vimUtils.buildVimPluginFrom2Nix {
    pname = "j-hui";
    version = "flake-lock";
    src = inputs.fidget-nvim;
    meta.homepage = "https://github.com/j-hui/fidget.nvim";
  };
  nvim-luaref = vimUtils.buildVimPluginFrom2Nix {
    pname = "nvim-luaref";
    version = "flake-lock";
    src = inputs.nvim-luaref;
    meta.homepage = "https://github.com/milisims/nvim-luaref";
  };
}
