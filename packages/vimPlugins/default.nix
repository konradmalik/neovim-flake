{ vimUtils, inputs }:
{
  fidget-nvim = vimUtils.buildVimPluginFrom2Nix {
    pname = "j-hui";
    version = "flake-lock";
    src = inputs.fidget-nvim;
    meta.homepage = "https://github.com/j-hui/fidget.nvim";
  };
  neo-tree-nvim = vimUtils.buildVimPluginFrom2Nix {
    pname = "neo-tree.nvim";
    version = "flake-lock";
    src = inputs.neo-tree-nvim;
    meta.homepage = "https://github.com/nvim-neo-tree/neo-tree.nvim";
  };
  nvim-luaref = vimUtils.buildVimPluginFrom2Nix {
    pname = "nvim-luaref";
    version = "flake-lock";
    src = inputs.nvim-luaref;
    meta.homepage = "https://github.com/milisims/nvim-luaref";
  };
}
