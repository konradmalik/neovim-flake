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
      # plugins
      dependencies = pkgs.callPackage ./mkDependencies.nix {
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
      inherit (dependencies) plugins systemDeps;

      # config
      config = pkgs.callPackage ../../config { };

      # neovim
      neovimNightly = inputs'.neovim-nightly-overlay.packages.default;
      neovim-pde = pkgs.callPackage ./neovim-pde.nix {
        inherit config plugins systemDeps;
        neovim = neovimNightly;
      };
    in
    {
      packages = {
        default = neovim-pde;

        inherit neovim-pde config;
        neovim-pde-dev = pkgs.callPackage ./neovim-pde-dev.nix { inherit neovim-pde config; };
        nvim-typecheck = pkgs.callPackage ./nvim-typecheck.nix { };
        full-luarc-json = pkgs.mk-luarc-json {
          nvim = neovimNightly;
          inherit plugins;
        };
        no-plugins-luarc-json = pkgs.mk-luarc-json {
          # use not-nightly neovim because busted uses that as well
        };
      };
    };
}
