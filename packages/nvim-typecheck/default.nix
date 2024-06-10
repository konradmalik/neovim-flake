{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  neovim,
  lua-language-server,
}:
let
  luvit-meta = fetchFromGitHub {
    owner = "Bilal2453";
    repo = "luvit-meta";
    rev = "ce76f6f6cdc9201523a5875a4471dcfe0186eb60";
    hash = "sha256-zAAptV/oLuLAAsa2zSB/6fxlElk4+jNZd/cPr9oxFig=";
  };
in
stdenv.mkDerivation {
  name = "nvim-typecheck";
  version = "v2";
  src = fetchFromGitHub {
    owner = "stevearc";
    repo = "nvim-typecheck-action";
    rev = "ed62b8e40283bad58cad8e7743045705104b8070";
    hash = "sha256-uLaux4KJD3dIQaBc1EOjEwJ0Ga64WaMdSsFi2IrOFKI=";
  };

  postPatch = ''
    patchShebangs --host ./typecheck.sh
    substituteInPlace ./typecheck.lua \
      --replace-fail 'https://github.com/Bilal2453/luvit-meta' '${luvit-meta}'
  '';

  preferLocalBuild = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out
    cp -r ./ $out/bin
    mv $out/bin/typecheck.sh $out/bin/nvim-typecheck
  '';

  postFixup = ''
    wrapProgram $out/bin/nvim-typecheck \
      --prefix PATH : ${
        lib.makeBinPath [
          neovim
          lua-language-server
        ]
      }
  '';
}
