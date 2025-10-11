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
  # TODO until fixed on unstable for darwin
  ((builtins.getFlake "github:NixOS/nixpkgs/84c256e42600cb0fdf25763b48d28df2f25a0c8b")
    .legacyPackages.${pkgs.system}.zls
  )

  # debuggers
  delve
  netcoredbg
]
++ lib.optionals stdenvNoCC.isLinux [
  # for faster filewatching in lsps
  inotify-tools
]
