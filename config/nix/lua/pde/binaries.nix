{ lib, pkgs }:
let
  # FIXME once stdio lands in unstable
  # https://github.com/NixOS/nixpkgs/pull/379787
  inherit
    ((builtins.getFlake "github:konradmalik/nixpkgs/1cd039866ff4728d85430ba66af60ba790a4789b")
      .legacyPackages.${pkgs.system}
    )
    roslyn-ls
    ;

  debugpy = pkgs.python3.withPackages (p: [ p.debugpy ]);
in
pkgs.writeTextDir "lua/pde/binaries.lua" # lua
  ''
    local fs = require("pde.fs")

    local nix = {
        -- formatters
        black = "${lib.getExe pkgs.black}",
        isort = "${lib.getExe pkgs.isort}",
        nixfmt = "${lib.getExe pkgs.nixfmt-rfc-style}",
        prettier = "${lib.getExe pkgs.nodePackages.prettier}",
        rustfmt = "${lib.getExe pkgs.rustfmt}",
        shfmt = "${lib.getExe pkgs.shfmt}",
        stylua = "${lib.getExe pkgs.stylua}",
        taplo = "${lib.getExe pkgs.taplo}",

        -- linters
        golangci_lint = "${lib.getExe pkgs.golangci-lint}",
        jq = "${lib.getExe pkgs.jq}",
        shellcheck = "${lib.getExe pkgs.shellcheck}",

        -- lsps
        clangd = "${lib.getExe' pkgs.clang-tools "clangd"}",
        efm = "${lib.getExe pkgs.efm-langserver}",
        gopls = "${lib.getExe pkgs.gopls}",
        jsonls = "${lib.getExe pkgs.nodePackages.vscode-json-languageserver}",
        ltex_ls = "${lib.getExe' pkgs.ltex-ls "ltex-ls"}",
        lua_ls = "${lib.getExe pkgs.lua-language-server}",
        nixd = "${lib.getExe pkgs.nixd}",
        pyright = "${lib.getExe' pkgs.pyright "pyright-langserver"}",
        roslyn_ls = "${lib.getExe roslyn-ls}",
        rust_analyzer = "${lib.getExe pkgs.rust-analyzer}",
        terraformls = "${lib.getExe pkgs.terraform-ls}",
        yamlls = "${lib.getExe pkgs.yaml-language-server}",
        zls = "${lib.getExe pkgs.zls}",

        -- debuggers
        debugpy = "${debugpy}/bin/python",
        delve = "${lib.getExe' pkgs.delve "dlv-dap"}",
        netcoredbg = "${lib.getExe pkgs.netcoredbg}",

        -- other
        node = "${lib.getExe pkgs.nodejs-slim}",
    }

    local cache = {}

    local function get_lazily(binary)
      return function()
        local cached = cache[binary]
        if cached then
          return cached
        end

        local exe = fs.from_path_or_default(binary, nix[binary])
        if not exe then
          vim.notify("cannot find '" .. binary .. "' binary in PATH nor in binaries.lua", vim.log.levels.ERROR)
        end
        cache[binary] = exe
        return exe
      end
    end

    local ret = {}

    setmetatable(ret, {
      __index = function(tbl, key)
        return get_lazily(key)
      end,
    })

    return ret
  ''
