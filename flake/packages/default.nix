{ inputs, ... }:
{
  perSystem =
    { inputs', pkgs, ... }:
    let
      neovimPlugins = pkgs.callPackage ./vendoredPlugins.nix {
        inherit inputs;
        all-treesitter-grammars = pkgs.vimPlugins.nvim-treesitter.allGrammars;
      };
    in
    {
      packages =
        let
          nightlyNeovim = inputs'.neovim-nightly-overlay.packages.default;
          neovim-pde = pkgs.callPackage ./neovim-pde {
            inherit neovimPlugins;
            neovim = nightlyNeovim;
          };
        in
        {
          inherit neovim-pde;
          neovim-pde-dev = pkgs.callPackage ./neovim-pde-dev.nix { inherit neovim-pde; };
          default = neovim-pde;
          config = neovim-pde.passthru.config;
          nvim-typecheck = pkgs.callPackage ./nvim-typecheck.nix { neovim = nightlyNeovim; };
        };
    };
}
