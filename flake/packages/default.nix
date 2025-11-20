{ inputs, lib, ... }:
{
  perSystem =
    {
      inputs',
      pkgs,
      ...
    }:
    let
      neovim-nightly = inputs'.neovim-nightly-overlay.packages.default;

      mkNeovim = pkgs.callPackage ./mkNeovim.nix { nvim = neovim-nightly; };

      mkPlugins = pkgs.callPackage ./plugins.nix { };

      plugins = mkPlugins {
        inherit
          pkgs
          lib
          inputs
          inputs'
          ;
      };

      extraPackages = pkgs.callPackage ./binaries.nix {
        efm-langserver = inputs'.efm-langserver.packages.default;
      };
    in
    {
      packages = rec {
        default = nvim;

        nvim = mkNeovim {
          inherit plugins extraPackages;
        };

        nvim-dev =
          let
            devPkg = mkNeovim {
              inherit plugins extraPackages;
              devMode = true;
            };

            devBin = pkgs.writeShellScriptBin "nvim-dev" ''
              if [[ ! $NVIM_PDE_DEV_CONFIG_PATH ]]; then
                echo "must set NVIM_PDE_DEV_CONFIG_PATH"
                exit 1
              fi

              XDG_CONFIG_DIRS="$NVIM_PDE_DEV_CONFIG_PATH" \
                ${lib.getExe devPkg} -u $NVIM_PDE_DEV_CONFIG_PATH/nvim/init.lua "$@"
            '';
          in
          devBin.overrideAttrs {
            shellHook = ''
              export NVIM_PDE_DEV_CONFIG_PATH="$PWD"
            '';
          };
        nvim-typecheck = pkgs.callPackage ./nvim-typecheck.nix { };
        nvim-luarc-json = pkgs.mk-luarc-json {
          inherit plugins;
          nvim = neovim-nightly;
        };
        busted-luarc-json = pkgs.mk-luarc-json {
          # use not-nightly neovim because busted uses that as well
        };
      };
    };
}
