{ pkgs }:
with pkgs;
[
  # formatters
  nixfmt
  prettier
  ruff
  rustfmt
  shfmt
  stylua
  taplo

  # linters
  shellcheck

  # lsps
  bash-language-server
  clang-tools
  golangci-lint-langserver
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
