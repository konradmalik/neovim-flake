{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  neovim,
  lua-language-server,
}:
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
