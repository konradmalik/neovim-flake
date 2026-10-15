{ pkgs }:
with pkgs;
[
  # formatters
  black
  isort
  nixfmt
  prettier
  rustfmt
  shfmt
  stylua
  taplo

  # linters
  golangci-lint-langserver
  shellcheck

  # lsps
  bash-language-server
  clang-tools
  gopls
  harper
  lua-language-server
  marksman
  nixd
  vscode-json-languageserver
  roslyn-ls
  rust-analyzer
  terraform-ls
  ty
  yaml-language-server
  zls
]
++ lib.optionals stdenvNoCC.hostPlatform.isLinux [
  # for faster filewatching in lsps
  inotify-tools
]
