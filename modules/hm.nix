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
        default = false;
        description = ''
          Symlink <command>vi</command> to <command>nvim</command> binary.
        '';
      };

      vimAlias = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Symlink <command>vim</command> to <command>nvim</command> binary.
        '';
      };

      vimdiffAlias = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Alias <command>vimdiff</command> to <command>nvim -d</command>.
        '';
      };

      simpleDefaultEditor = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to configure <command>nvim -u NONE</command> as the default
          editor using the <envar>EDITOR</envar>, <envar>GIT_EDITOR</envar>
          and <envar>VISUAL</envar> environment variable.
        '';
      };

      extendGitIgnores = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to add misc files generated by neovim, lsp, dap etc. to default global git ignore.
        '';
      };

      appName = mkOption {
        type = types.str;
        default = "neovim-pde-hm";
        description = "NVIM_APPNAME to use";
      };

      isolated = mkOption {
        type = types.bool;
        default = false;
        description = ''
          If true, will work as if run from the flake directly (with -u flag, meaning no exrc files loaded, no local
          config etc.
          If false, will symlink it's config to `$XDG_CONFIG_HOME/$NVIM_APPNAME` and run without -u flag.
        '';
      };

      colorscheme = mkOption {
        type = types.str;
        default = "catppuccin-macchiato";
        description = "colorscheme slug. See colorscheme.lua";
      };
    };
  };

  config =
    let
      defaultBundle = self.lib.${pkgs.system}.bundle;
      overridenBundle = defaultBundle.override { inherit (cfg) appName colorscheme isolated viAlias vimAlias; };
    in
    mkIf cfg.enable {
      home.packages = [ overridenBundle.nvim ];

      home.sessionVariables = mkIf
        cfg.simpleDefaultEditor
        {
          # should be like that but many programs don't respect VISUAL in favor of EDITOR so...
          # EDITOR = "nvim -u NONE -e";
          EDITOR = "nvim -u NORC";
          # no rc makes it start faster than the speed of light
          VISUAL = "nvim -u NORC";
          GIT_EDITOR = "nvim -u NONE";
        };

      xdg.configFile = mkIf (!cfg.isolated) {
        ${cfg.appName} = {
          source = overridenBundle.config;
          recursive = true;
        };
      };

      programs.git.ignores = mkIf
        cfg.extendGitIgnores
        [
          ".netcoredbg_hist"
          ".null-ls*"
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
