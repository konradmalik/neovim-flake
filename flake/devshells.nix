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
                ln -fs ${self'.packages.full-luarc-json} ./config/native/.luarc.json
                ln -fs ${self'.packages.no-plugins-luarc-json} ./.luarc.json
              '';
          packages =
            (with pkgs; [
              busted-nlua
              luajitPackages.luacheck
              stylua
            ])
            ++ [
              self'.packages.nvim-typecheck
              neovim-pde-dev
            ];
        };
    };
}
