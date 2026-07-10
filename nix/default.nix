{
  pkgs,
  lib,
  inputs,
}:
let
  nvim = pkgs.nvim-nightly;

  mkNeovim = pkgs.callPackage ./mkNeovim.nix { inherit nvim; };
  mkPlugins = pkgs.callPackage ./plugins.nix { inherit nvim; };

  plugins = mkPlugins {
    inherit
      pkgs
      lib
      inputs
      ;
  };

  extraPackages = import ./binaries.nix { inherit pkgs; };
in
{
  nvim-pkg = mkNeovim {
    inherit plugins extraPackages;
  };

  nvim-dev =
    (mkNeovim {
      inherit plugins extraPackages;
      appName = "nvim-dev";
      devMode = true;
    }).overrideAttrs
      {
        shellHook =
          # bash
          ''
            # allow quick iteration of lua configs
            ln -Tfns $PWD/nvim ~/.config/nvim-dev
          '';
      };

  nvim-typecheck = pkgs.callPackage ./nvim-typecheck.nix { };

  nvim-luarc-json = pkgs.mk-luarc-json {
    inherit plugins nvim;
  };
  busted-luarc-json = pkgs.mk-luarc-json {
    # use stable (not-nightly) neovim because busted uses that as well
    nvim = pkgs.neovim-unwrapped;
  };
}
