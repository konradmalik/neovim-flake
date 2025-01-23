{
  perSystem =
    { pkgs, self', ... }:
    {
      apps = {
        default = self'.apps.neovim-pde;
        neovim-pde = {
          type = "app";
          program = pkgs.lib.getExe self'.packages.neovim-pde;
        };
        neovim-pde-dev = {
          type = "app";
          program = pkgs.lib.getExe self'.packages.neovim-pde-dev;
        };
      };
    };
}
