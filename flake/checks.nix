{
  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      checks =
        let
          fs = lib.fileset;
          makeCheckJob =
            name: cmd:
            pkgs.stdenvNoCC.mkDerivation {
              inherit name;

              checkInputs = [ pkgs.neovim ];
              dontBuild = true;
              dontConfigure = true;
              src = builtins.path {
                inherit name;
                path = fs.toSource {
                  root = ./..;
                  fileset = fs.unions [
                    ./../nvim
                    ./../.luacheckrc
                  ];
                };
              };
              doCheck = true;
              preCheck = ''
                ln -s ${self'.packages.nvim-luarc-json} ./nvim/.luarc.json
              '';
              checkPhase = ''
                runHook preCheck
                ${cmd}
                runHook postCheck
              '';
              installPhase = ''
                touch "$out"
              '';
            };
        in
        {
          luacheck = makeCheckJob "luacheck" ''
            ${lib.getExe pkgs.lua.pkgs.luacheck} --codes --no-cache ./nvim
          '';
          typecheck = makeCheckJob "typecheck" ''
            ${lib.getExe self'.packages.nvim-typecheck} ./nvim
          '';
        };
    };
}
