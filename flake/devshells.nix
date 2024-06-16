{
  perSystem =
    { pkgs, self', ... }:
    {
      devShells.default =
        let
          neovim-pde-dev = self'.packages.neovim-pde-dev;
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
              self'.packages.nvim-typecheck
              neovim-pde-dev
            ];
        };
    };
}
