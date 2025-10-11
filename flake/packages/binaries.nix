{ efm-langserver, pkgs }:
with pkgs;
[
  # formatters
  black
  isort
  nixfmt-rfc-style
  nodePackages.prettier
  rustfmt
  shfmt
  stylua
  taplo

  # linters
  golangci-lint-langserver
  jq
  shellcheck

  # lsps
  clang-tools
  efm-langserver
  gopls
  harper
  lua-language-server
  marksman
  nixd
  nodePackages.vscode-json-languageserver
  roslyn-ls
  rust-analyzer
  terraform-ls
  ty
  yaml-language-server
  zls

  # debuggers
  delve
  # TODO until fixed on unstable
  ((builtins.getFlake "github:NixOS/nixpkgs/2e6ba6ec4509645504c375f2ede9935d540405c6")
    .legacyPackages.${pkgs.system}.netcoredbg
  )
]
++ lib.optionals stdenvNoCC.isLinux [
  # for faster filewatching in lsps
  inotify-tools
]
