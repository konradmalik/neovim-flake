{
  perSystem =
    { pkgs, config, ... }:
    {
      apps.default = {
        type = "app";
        program = pkgs.lib.getExe config.packages.neovim-pde;
      };
    };
}
