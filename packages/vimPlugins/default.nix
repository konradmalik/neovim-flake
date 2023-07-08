{ callPackage, inputs }:
{
  fidget-nvim = callPackage ./fidget-nvim.nix { src = inputs.fidget-nvim; };
  nvim-luaref = callPackage ./nvim-luaref.nix { src = inputs.nvim-luaref; };
}
