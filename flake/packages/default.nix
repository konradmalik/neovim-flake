{ inputs, ... }:
{
  perSystem =
    { inputs', pkgs, ... }:
    let
      neovimPlugins = pkgs.callPackages ./neovimPlugins.nix {
        inherit inputs inputs';
        all-treesitter-grammars = pkgs.vimPlugins.nvim-treesitter.allGrammars;
      };
      nightlyNeovim = inputs'.neovim-nightly-overlay.packages.default;
      nvimConfig = pkgs.callPackage ../../config { };
      pluginsList = pkgs.callPackage ./pluginsList.nix { inherit neovimPlugins; };
      neovim-pde = pkgs.callPackage ./neovim-pde {
        inherit pluginsList nvimConfig;
        neovim = nightlyNeovim;
      };
    in
    {
      packages = {
        inherit neovim-pde nvimConfig;
        neovim-pde-dev = pkgs.callPackage ./neovim-pde-dev.nix { inherit neovim-pde nvimConfig; };
        default = neovim-pde;
        nvim-typecheck = pkgs.callPackage ./nvim-typecheck.nix { neovim = nightlyNeovim; };
      } // neovimPlugins;
    };
}
