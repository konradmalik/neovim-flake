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
  clang-tools
  efm-langserver
  gopls
  nodePackages.vscode-json-languageserver
  ltex-ls-plus
  lua-language-server
  nixd
  basedpyright
  roslyn-ls
  rust-analyzer
  terraform-ls
  yaml-language-server
  zls

  # debuggers
  delve
  netcoredbg
]
