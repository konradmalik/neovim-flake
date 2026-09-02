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

  # image conversion for vim.ui.img, which only transmits png
  imagemagick

  # linters
  golangci-lint-langserver
  jq
  shellcheck

  # lsps
  clang-tools
  flint-ls
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
