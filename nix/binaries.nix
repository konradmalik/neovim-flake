{ pkgs }:
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
  roslyn-ls
  rust-analyzer
  terraform-ls
  yaml-language-server
  zls

  # debuggers
  (writeShellScriptBin "debugpy" ''
    exec ${python3.withPackages (p: [ p.debugpy ])}/bin/python "$@"
  '')
  delve
  netcoredbg
]
++ lib.optionals stdenvNoCC.isLinux [
  # for faster filewatching in lsps
  inotify-tools
]
