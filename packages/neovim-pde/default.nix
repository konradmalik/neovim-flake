{ pkgs, lib }:
lib.makeOverridable (
  { appName ? "neovim-pde", colorscheme ? "catppuccin-macchiato", palette ? null, viAlias ? false, vimAlias ? false, isolated ? true }:
  let
    config = pkgs.callPackage ../../config { inherit appName colorscheme palette; };
    plugins = pkgs.callPackage ./plugins.nix { };
    deps = pkgs.callPackage ./deps.nix { };
    extraMakeWrapperArgs =
      [ "--set" "NVIM_APPNAME" appName ]
      ++ lib.optionals (deps != [ ])
        [ "--suffix" "PATH" ":" "${lib.makeBinPath deps}" ]
      ++ lib.optionals isolated
        [
          "--add-flags"
          "--cmd \"lua vim.opt.rtp:append('${config}')\""
          "--add-flags"
          "-u \"${config}/init.lua\""
        ];

    neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
      inherit plugins viAlias vimAlias;
      withPython3 = false;
      # copilot dependency
      withNodeJs = true;
      withRuby = false;
    };
  in
  {
    inherit config;
    nvim = (pkgs.wrapNeovimUnstable pkgs.neovim
      (neovimConfig // {
        # there is a bug in nix and if we provide a list here, then the wrapper will duplicate most of the entries.
        # see: pkgs/applications/editors/neovim/wrapper.nix#L42 "commonWrapperArgs = (lib.optionals (lib.isList wrapperArgs) wrapperArgs)
        wrapperArgs = lib.escapeShellArgs (neovimConfig.wrapperArgs ++ extraMakeWrapperArgs);
        wrapRc = false;
      }));
  }
)
