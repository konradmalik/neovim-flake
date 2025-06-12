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
  ((builtins.getFlake "github:konradmalik/nixpkgs/0701c18b5670f0a1f972e9546e8bfa4b22defc82")
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
