{ callPackage, inputs }:
{
  mini-base16 = callPackage ./mini-base16.nix { src = inputs.mini-base16; };
  nvim-luaref = callPackage ./nvim-luaref.nix { src = inputs.nvim-luaref; };
}
