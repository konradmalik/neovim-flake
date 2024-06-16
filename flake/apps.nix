{
  perSystem =
    { pkgs, self', ... }:
    {
      apps.default = {
        type = "app";
        program = pkgs.lib.getExe self'.packages.neovim-pde;
      };
    };
}
