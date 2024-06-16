{
  perSystem =
    { pkgs, config, ... }:
    {
      devShells.default =
        let
          neovim-pde-dev = config.packages.neovim-pde-dev;
        in
        pkgs.mkShell {
          name = "neovim-shell";
          shellHook = neovim-pde-dev.shellHook;
          packages =
            (with pkgs; [
              stylua
              lua.pkgs.luacheck
            ])
            ++ [
              config.packages.nvim-typecheck
              neovim-pde-dev
            ];
        };
    };
}
