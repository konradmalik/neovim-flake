{ pkgs }:
with pkgs;
[
  black
  isort
  nixfmt-rfc-style
  nodePackages.prettier
  rustfmt
  shfmt
  stylua
  taplo

  # linters
  golangci-lint
  jq
  shellcheck

  # lsps
  basedpyright
  clang-tools
  efm-langserver
  gopls
  harper
  lua-language-server
  nixd
  nodePackages.vscode-json-languageserver
  roslyn-ls
  rust-analyzer
  terraform-ls
  yaml-language-server
  zls

  # debuggers
  delve
  netcoredbg
]
