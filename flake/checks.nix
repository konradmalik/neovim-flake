{
  perSystem =
    { pkgs, self', ... }:
    {
      checks =
        let
          fs = pkgs.lib.fileset;
          makeCheckJob =
            name: cmd:
            pkgs.stdenvNoCC.mkDerivation {
              inherit name;
              dontBuild = true;
              dontConfigure = true;
              src = builtins.path {
                inherit name;
                path = fs.toSource {
                  root = ./..;
                  fileset = fs.unions [
                    ./../config/nvim
                    ./../.luacheckrc
                  ];
                };
              };
              doCheck = true;
              checkPhase = cmd;
              installPhase = ''
                touch "$out"
              '';
            };
        in
        {
          luacheck = makeCheckJob "luacheck" ''
            ${pkgs.lua.pkgs.luacheck}/bin/luacheck --codes --no-cache ./config/nvim
          '';
          typecheck = makeCheckJob "typecheck" ''
            ${self'.packages.nvim-typecheck}/bin/nvim-typecheck ./config/nvim
          '';
        };
    };
}
