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
  basedpyright
  clang-tools
  efm-langserver
  gopls
  harper
  lua-language-server
  marksman
  nixd
  nodePackages.vscode-json-languageserver
  # TODO until fixed on unstable
  ((builtins.getFlake "github:NixOS/nixpkgs/596312aae91421d6923f18cecce934a7d3bfd6b8")
    .legacyPackages.${pkgs.system}.roslyn-ls
  )
  rust-analyzer
  terraform-ls
  yaml-language-server
  zls

  # debuggers
  delve
  netcoredbg
]
++ lib.optionals stdenvNoCC.isLinux [
  # for faster filewatching in lsps
  inotify-tools
]
