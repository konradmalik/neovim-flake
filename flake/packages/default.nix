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
      pluginsPack = pkgs.callPackage ./neovim-pde/pluginManager.nix {
        pluginsList = (
          import ./plugins.nix {
            inherit (pkgs) vimUtils neovimUtils;
            inherit
              pkgs
              lib
              inputs
              inputs'
              ;
            all-treesitter-grammars = pkgs.vimPlugins.nvim-treesitter.allGrammars;
          }
        );
      };

      inherit (pluginsPack) plugins;
      systemDeps = lib.unique pluginsPack.systemDeps;

      nightlyNeovim = inputs'.neovim-nightly-overlay.packages.default;
      nvimConfig = pkgs.callPackage ../../config { };
      neovim-pde = pkgs.callPackage ./neovim-pde {
        inherit nvimConfig plugins systemDeps;
        neovim = nightlyNeovim;
      };
    in
    {
      packages = {
        inherit neovim-pde nvimConfig;
        neovim-pde-dev = pkgs.callPackage ./neovim-pde-dev.nix { inherit neovim-pde nvimConfig; };
        default = neovim-pde;
        nvim-typecheck = pkgs.callPackage ./nvim-typecheck.nix { neovim = nightlyNeovim; };
        nvim-luarc-json = pkgs.mk-luarc-json {
          nvim = nightlyNeovim;
          inherit plugins;
        };
      };
    };
}
