{ getSystem, ... }:
{
  flake = {
    homeManagerModules.default =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      with lib;
      let
        cfg = config.programs.neovim-pde;
      in
      {
        options = {
          programs.neovim-pde = {
            enable = mkEnableOption "Neovim PDE";

            viAlias = mkOption {
              type = types.bool;
              default = true;
              description = ''
                Symlink <command>vi</command> to <command>nvim</command> binary.
              '';
            };

            vimAlias = mkOption {
              type = types.bool;
              default = true;
              description = ''
                Symlink <command>vim</command> to <command>nvim</command> binary.
              '';
            };

            vimdiffAlias = mkOption {
              type = types.bool;
              default = true;
              description = ''
                Alias <command>vimdiff</command> to <command>nvim -d</command>.
              '';
            };

            extendGitIgnores = mkOption {
              type = types.bool;
              default = true;
              description = ''
                Whether to add misc files generated by neovim, lsp, dap etc. to default global git ignore.
              '';
            };

            appName = mkOption {
              type = types.str;
              default = "neovim-pde-hm";
              description = "NVIM_APPNAME to use";
            };

            selfContained = mkOption {
              type = types.bool;
              default = false;
              description = ''
                If true, will work as if run from the flake directly (with -u flag, meaning no exrc files loaded, no
                init.lua/init.vim config etc.
                If false, will symlink it's config to `$XDG_CONFIG_HOME/$NVIM_APPNAME` and run without -u flag.
              '';
            };

            cleanLspLog = mkOption {
              type = types.bool;
              default = false;
              description = ''
                Whether to remove lsp.log file on each config change.
                Helps to prevent it from growing indefinately without manual interventions.
              '';
            };

            systemLua = mkOption {
              type = types.str;
              default = # lua
                ''
                  return {}
                '';
              description = ''
                A lua script contents which should return
                a table. This table is then used in Lua code
                to understand some system-variables like repository path or
                notes (obsidian) path.
              '';
            };
          };
        };

        config =
          let
            nvim = (getSystem pkgs.system).packages.neovim-pde.override {
              inherit (cfg)
                appName
                selfContained
                viAlias
                vimAlias
                ;
            };
            nvimConfig = (getSystem pkgs.system).packages.nvimConfig.override { inherit (cfg) systemLua; };
          in
          mkIf cfg.enable {
            home.packages = [ nvim ];

            home.sessionVariables = {
              # should be like that but many programs don't respect VISUAL in favor of EDITOR so...
              # EDITOR = "nvim -u NONE -e";
              EDITOR = lib.mkDefault (lib.getExe nvim);
              VISUAL = lib.mkDefault (lib.getExe nvim);
              GIT_EDITOR = lib.mkDefault "${lib.getExe nvim} -u NONE";
            };

            xdg.configFile.${cfg.appName} = {
              enable = !cfg.selfContained;
              source = nvimConfig;
              recursive = true;
              onChange =
                ''
                  rm -rf ${config.xdg.cacheHome}/${cfg.appName}
                ''
                + lib.optionalString cfg.cleanLspLog ''
                  rm -f ${config.xdg.stateHome}/${cfg.appName}/lsp.log
                '';
            };

            programs.git.ignores = mkIf cfg.extendGitIgnores [
              ".netcoredbg_hist"
              ".nvim.lua"
            ];

            programs.bash.shellAliases = mkIf cfg.vimdiffAlias { vimdiff = "nvim -d"; };
            programs.fish.shellAliases = mkIf cfg.vimdiffAlias { vimdiff = "nvim -d"; };
            programs.zsh.shellAliases = mkIf cfg.vimdiffAlias { vimdiff = "nvim -d"; };
          };
      };
  };
}
