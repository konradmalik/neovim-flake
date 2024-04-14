self:
{ config, lib, pkgs, ... }:
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

      self-contained = mkOption {
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
    };
  };

  config =
    let
      nvim = self.packages.${pkgs.system}.neovim.override { inherit (cfg) appName self-contained viAlias vimAlias; };
    in
    mkIf cfg.enable {
      home.packages = [ nvim ];

      home.sessionVariables = {
        # should be like that but many programs don't respect VISUAL in favor of EDITOR so...
        # EDITOR = "nvim -u NONE -e";
        EDITOR = lib.mkDefault "${nvim}/bin/nvim";
        VISUAL = lib.mkDefault "${nvim}/bin/nvim";
        GIT_EDITOR = lib.mkDefault "${nvim}/bin/nvim -u NONE";
      };

      xdg.configFile.${cfg.appName} = {
        enable = !cfg.self-contained;
        source = nvim.passthru.config;
        recursive = true;
        onChange = ''
          rm -rf ${config.xdg.cacheHome}/${cfg.appName}
        '' + lib.optionalString
          cfg.cleanLspLog
          ''
            rm -f ${config.xdg.stateHome}/${cfg.appName}/lsp.log
          '';

      };

      programs.git.ignores = mkIf
        cfg.extendGitIgnores
        [
          ".netcoredbg_hist"
          ".nvim.lua"
        ];

      programs.bash.shellAliases = mkIf
        cfg.vimdiffAlias
        { vimdiff = "nvim -d"; };
      programs.fish.shellAliases = mkIf
        cfg.vimdiffAlias
        { vimdiff = "nvim -d"; };
      programs.zsh.shellAliases = mkIf
        cfg.vimdiffAlias
        { vimdiff = "nvim -d"; };
    };
}
