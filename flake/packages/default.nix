{ inputs, ... }:
{
  perSystem =
    {
      inputs',
      pkgs,
      lib,
      ...
    }:
    let
      pluginsList = import ./plugins.nix {
        inherit (pkgs) vimUtils neovimUtils;
        inherit
          pkgs
          lib
          inputs
          inputs'
          ;
        all-treesitter-grammars = pkgs.vimPlugins.nvim-treesitter.allGrammars;
      };
      nightlyNeovim = inputs'.neovim-nightly-overlay.packages.default;
      nvimConfig = pkgs.callPackage ../../config { };
      neovim-pde = pkgs.callPackage ./neovim-pde {
        inherit nvimConfig pluginsList;
        neovim = nightlyNeovim;
      };
    in
    {
      packages = {
        inherit neovim-pde nvimConfig;
        neovim-pde-dev = pkgs.callPackage ./neovim-pde-dev.nix { inherit neovim-pde nvimConfig; };
        default = neovim-pde;
        nvim-typecheck = pkgs.callPackage ./nvim-typecheck.nix { neovim = nightlyNeovim; };
      };
    };
}
