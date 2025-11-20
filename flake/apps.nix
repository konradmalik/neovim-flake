{
  perSystem =
    { pkgs, self', ... }:
    {
      apps = {
        default = self'.apps.nvim;
        nvim = {
          type = "app";
          program = pkgs.lib.getExe self'.packages.nvim;
        };
        nvim-dev = {
          type = "app";
          program = pkgs.lib.getExe self'.packages.nvim-dev;
        };
      };
    };
}
