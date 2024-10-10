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
          shellHook =
            neovim-pde-dev.shellHook
            +
              # bash
              ''
                # symlink the .luarc.json generated in the overlay
                ln -fs ${self'.packages.nvim-luarc-json} ./config/native/.luarc.json
              '';
          packages =
            (with pkgs; [
              stylua
              luajitPackages.luacheck
            ])
            ++ [
              self'.packages.nvim-typecheck
              neovim-pde-dev
            ];
        };
    };
}
