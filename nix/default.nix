{
  pkgs,
  inputs,
}:
let
  nvim = pkgs.nvim-nightly;

  mkNeovim = pkgs.callPackage ./mkNeovim.nix { inherit nvim; };

  plugins = import ./plugins.nix { inherit pkgs inputs nvim; };

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
  busted-luarc-json =
    let
      luarc = pkgs.mk-luarc {
        # busted runs specs on this same neovim, see the nlua override in flake.nix
        inherit nvim;
      };
    in
    pkgs.luarc-to-json (
      luarc
      // {
        workspace = luarc.workspace // {
          library = luarc.workspace.library ++ [ "../nvim/lua" ];
        };
      }
    );
}
