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
      neovim-pde = pkgs.callPackage ./neovim-pde {
        inherit neovimPlugins;
        neovim = nightlyNeovim;
        config = nvimConfig;
      };
    in
    {
      packages = {
        inherit neovim-pde;
        neovim-pde-dev = pkgs.callPackage ./neovim-pde-dev.nix { inherit neovim-pde nvimConfig; };
        default = neovim-pde;
        config = nvimConfig;
        nvim-typecheck = pkgs.callPackage ./nvim-typecheck.nix { neovim = nightlyNeovim; };
      } // neovimPlugins;
    };
}
