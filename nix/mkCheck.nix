{
  stdenvNoCC,
  nvim-luarc-json,
  lib,
}:
let
  fs = lib.fileset;
in
name: cmd:
stdenvNoCC.mkDerivation {
  inherit name;
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

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;
  dontInstall = true;

  doCheck = true;
  checkInputs = [ ];
  preCheck = ''
    ln -s ${nvim-luarc-json} ./nvim/.luarc.json
  '';
  checkPhase = ''
    runHook preCheck
    ${cmd}
    runHook postCheck
  '';
}
