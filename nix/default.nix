{ inputs }:
final: prev:
let
  pkgs = final;
  inherit (pkgs) lib;

  mkNeovim = pkgs.callPackage ./mkNeovim.nix { nvim = pkgs.nvim-nightly; };

  mkPlugins = pkgs.callPackage ./plugins.nix { };

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
        shellHook = ''
          # allow quick iteration of lua configs
          ln -Tfns $PWD/nvim ~/.config/nvim-dev
        '';
      };

  nvim-typecheck = pkgs.callPackage ./nvim-typecheck.nix { };

  nvim-luarc-json = pkgs.mk-luarc-json {
    inherit plugins;
    nvim = pkgs.neovim-nightly;
  };
  busted-luarc-json = pkgs.mk-luarc-json {
    # use not-nightly neovim because busted uses that as well
  };
}
