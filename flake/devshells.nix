{
  perSystem =
    { pkgs, self', ... }:
    {
      devShells.default =
        let
          nvim-dev = self'.packages.nvim-dev;
        in
        pkgs.mkShell {
          name = "neovim-shell";
          shellHook =
            nvim-dev.shellHook
            +
            # bash
            ''
              ln -fs ${self'.packages.nvim-luarc-json} ./nvim/.luarc.json
              ln -fs ${self'.packages.busted-luarc-json} ./spec/.luarc.json
            '';
          packages =
            (with pkgs; [
              gnumake
              busted-nlua
              luajitPackages.luacheck
              stylua
            ])
            ++ [
              self'.packages.nvim-typecheck
              nvim-dev
            ];
        };
    };
}
