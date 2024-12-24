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
    rev = "57d464c4acb5c2e66bd4145060f5dc9e96a7bbb7";
    hash = "sha256-c6AFyWwWzG8WyhFqo8F3+aa8mZYtRrdPizmwf9a5yQk=";
  };
in
stdenv.mkDerivation {
  name = "nvim-typecheck";
  version = "v2";
  src = fetchFromGitHub {
    owner = "stevearc";
    repo = "nvim-typecheck-action";
    rev = "d2d873b941473ca3b4c6df05f8ac55d6d63159b0";
    hash = "sha256-KSFac9MSO8jfraF9R7R9SG3RBHAUvIRcCZZBHu3QWEA=";
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
